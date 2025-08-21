#!/usr/bin/env ruby

# ODDB::Persistence -- oddb.org -- 29.02.2012 -- mhatakeyama@ywesee.com
# ODDB::Persistence -- oddb.org -- 26.02.2003 -- hwyss@ywesee.com

require "odba"

# Hash#key has been newly defined since Ruby 1.9 (Ruby 1.8.8)
# Hash#index has been obsolete since Ruby 1.9
class Hash
  alias_method :index, :key
end

# another monkey patch for CSV
class CSV
  puts "Attention: monkey-patching CSV::Cell"
  # deprecated
  class Cell < String
    @@first = false
    def initialize(data = "", is_null = false)
      unless @@first
        warn "Attention: monkey-patching CSV::Cell used by #{caller.join('\n')}"
        @@first = true
      end
      super(is_null ? "" : data)
    end

    def data
      to_s
    end
  end
end

module ODBA
  class Stub
    def odba_replace(name = nil)
      @receiver || begin
        @receiver = ODBA.cache.fetch(@odba_id, @odba_container)
        if @odba_container
          @odba_container.odba_replace_stubs(self, @receiver)
        end
        @receiver
      rescue ODBA::OdbaError
        msg = "ODBA::Stub was unable to replace #{@odba_class}:#{@odba_id} - "
        if @odba_container.respond_to?(:pointer)
          msg << @odba_container.pointer.to_s
        end
        names = @odba_container.instance_variables.select { |name|
          eql?(@odba_container.instance_variable_get(name))
        }
        msg << "[" << names.join(",") << "]"
        warn msg
      end
    end
  end
end

module ODDB
  module PersistenceMethods
    attr_reader :oid
    attr_accessor :pointer, :revision
    def init(app)
    end

    def structural_ancestors(app)
      if @pointer
        @pointer.ancestors.collect { |pointer| pointer.resolve(app) }
      end
    end

    def data_origin(key)
      data_origins[key.to_s]
    end

    def data_origins
      @data_origins ||= {}
    end

    def diff(values, app = nil)
      # adjust_types(values, app)
      result = {}
      adjust_types(values, app).each { |key, value|
        if respond_to?(key)
          oldval = send(key)
          if oldval.nil? || undiffable?(oldval) || value != oldval
            result.store(key, value)
          end
        end
      }
      result
    end

    def checkout
    end

    def nil_if_empty(value)
      val = value.to_s.strip
      val.empty? ? nil : val
    end

    def parent(app)
      @pointer.parent.resolve(app)
    end

    def pointer_descr
      self.class.to_s
    end

    def undiffable?(val)
      defined?(val.class::DISABLE_DIFF) && val.class::DISABLE_DIFF
    end

    def update_values(values, origin = nil)
      @revision = Time.now
      values.each { |key, value|
        key = key.to_s
        data_origins.store(key, origin)
        send(key + "=", value)
      }
    end

    private

    def adjust_types(values, app = nil)
      values
    end

    def checkout_helper(connections, remove_command)
      connections.each { |var|
        if var.respond_to?(remove_command)
          var.send(remove_command, self)
        end
      }
    end

    def set_oid
      @oid ||= odba_id
    end
  end

  module AccessorCheckMethod
    def define_check_class_methods(check_class_list)
      check_class_list.each do |accessor, klasses|
        define_method("#{accessor}=") do |arg|
          unless klasses.is_a?(Array)
            klasses = [klasses]
          end
          klasses << "NilClass"
          klasses.uniq!
          if klasses.include?(arg.class.to_s)
            instance_variable_set("@#{accessor}", arg)
          else
            arg_class = arg.class
            arg = if arg.respond_to?(:to_s)
              arg.to_s[0, 10]
            end
            raise TypeError.new("Accessor #{accessor} '#{arg}'(#{arg_class}) should be #{klasses.join(" or ")}")
          end
        end
      end
    end
  end

  module Persistence
    include PersistenceMethods
    include ODBA::Persistable
    ODBA_PREDEFINE_SERIALIZABLE = ["@data_origins"]
    odba_index :pointer
    def initialize(*args)
      @revision = Time.now
      super
      set_oid
    end

    class PathError < RuntimeError
      attr_reader :pointer
      def initialize(msg, pointer)
        @pointer = pointer
        super(msg)
      end
    end

    class UninitializedPathError < PathError
    end

    class InvalidPathError < PathError
    end

    class Pointer
      SECURE_COMMANDS = [
        :active_agent, :address, :address_suggestion, :atc_class,
        :analysis_group, :commercial_form, :company, :doctor, :hospital,
        :fachinfo, :feedback, :galenic_form, :galenic_group,
        :generic_group, :indication, :invoice,
        :address_suggestion, :migel_group, :subgroup, :product,
        :narcotic, :narcotics, :orphaned_fachinfo, :orphaned_patinfo,
        :package, :patent, :patinfo, :pdf_patinfo, :position,
        :poweruser, :registration, :sequence, :slate, :sl_entry,
        :sponsor, :substance, :user, :limitation_text, :minifi,
        :index_therapeuticus
      ]
      class << self
        def from_yus_privilege(string)
          ## does not support encapsulated pointers
          args = string.scan(/!([^!]+)/u).collect { |matches|
            matches.first.split(".").compact
          }
          new(*args)
        end

        private
      end
      def initialize(*args)
        @directions = args.collect { |arg| [arg].flatten }
      end

      def ancestors
        pointer = self
        ancestors = []
        while (pointer = pointer.parent)
          ancestors.unshift(pointer)
        end
        ancestors
      end

      def append(value)
        @directions << [] unless @directions.last
        last_step = @directions.last
        unless last_step.last == value
          last_step << value
        end
      end

      def creator
        Pointer.new([:create, self])
      end

      def dup
        directions = @directions.collect { |step| step.dup }
        Pointer.new(*directions)
      end

      def eql?(other)
        to_s.eql?(other.to_s)
      end

      def insecure?
        @directions.any? { |step|
          !SECURE_COMMANDS.include?(step.first.to_sym) \
          || step.any? { |arg|
            arg.is_a?(Pointer)
          }
        }
      end

      def issue_create(app)
        new_obj = resolve(app)
        unless new_obj.nil?
          return new_obj
        end
        pointer = dup
        command = pointer.directions.pop
        command[0] = "create_" << command.first.to_s
        hook = pointer.resolve(app)
        new_obj = hook.send(*command.compact)
        new_obj.pointer = self
        new_obj.init(app)
        # Only the hook must be stored in issue_create
        # because wie scan its connections for unsaved objects
        # see ODBA::Persistable
        # In the case where the newly created object were saved
        # *before* the hook, any intermediate collections might not
        # be properly stored, resulting in the newly created object
        # being inaccessible after a restart
        hook.odba_store
        new_obj
      rescue InvalidPathError, UninitializedPathError => e
        warn "Could not create: #{self}, reason: #{e.message}"
      end

      def issue_delete(app)
        obj = resolve(app)
        if obj.respond_to?(:odba_delete)
          ## checkout the object from all indices
          ## if this happens after hook.send(*command), some index-updates
          ## will fail.
          obj.odba_delete
        end
        if obj.respond_to?(:checkout)
          obj.checkout
        end
        pointer = dup
        command = pointer.directions.pop
        command[0] = "delete_" << command.first.to_s
        hook = pointer.resolve(app)
        if hook.respond_to?(command.first)
          hook.send(*command.compact)
          ### ODBA needs the delete_<command> method to call
          ### odba_store or odba_isolated_store on whoever was the
          ### last connection to this item.
        end
      rescue InvalidPathError, UninitializedPathError, ODBA::OdbaError => e
        warn "Could not delete: #{self}, reason: #{e.message}"
      end

      def issue_update(hook, values, origin = nil)
        obj = resolve(hook)
        if !obj.nil? and obj.respond_to?(:diff)
          diff = obj.diff(values, hook)
          unless diff.empty?
            obj.update_values(diff, origin)
            if defined?(PGresult)
              $stdout.puts "self #{obj.inspect} is PGresult" if obj.is_a?(PGresult)
              obj.odba_store unless obj.is_a?(PGresult)
            else
              $stdout.puts "self #{obj.inspect} is PG::Result" if obj.is_a?(PG::Result)
              obj.odba_store unless obj.is_a?(PG::Result)
            end
          end
        end
        obj
      end

      def last_step
        @directions.last.dup
      end

      def parent
        parent = dup
        parent.directions.pop
        parent unless parent.directions.empty?
      end

      def resolve(hook)
        Persistence.find_by_pointer(to_s) or begin
          lasthook = hook
          laststep = []
          @directions.each { |step|
            if hook.nil?
              call = laststep.shift
              args = laststep.join(",")
              msg = "#{self} -> #{lasthook.class}::#{call}(#{args}) returned nil"
              raise(UninitializedPathError.new(msg, self))
            elsif hook.respond_to?(step.first)
              lasthook = hook
              laststep = step
              hook = begin
                hook.send(*step)
              rescue
              end
            else
              call = step.shift
              args = step.join(",")
              msg = "#{self} -> undefined Method #{hook.class}::#{call}(#{args})"
              raise(InvalidPathError.new(msg, self))
            end
          }
          hook
        end
      end

      def skeleton
        @directions.collect { |step|
          cmd = step.first
          cmd.is_a?(Symbol) ? cmd : cmd.intern
        }
      end

      def to_s
        ":" << @directions.collect { |orig|
          step = orig.collect { |arg|
            if arg.is_a? Pointer
              arg
            else
              arg.to_s.gsub("%", "%%").gsub(/[:!,.]/u, '%\0')
            end
          }
          "!" << step.join(",")
        }.join << "."
      end

      def to_csv
        @directions.collect { |orig|
          step = orig.collect { |arg|
            if arg.is_a? Pointer
              arg
            else
              arg.to_s.gsub("%", "%%").gsub(/[:!,.]/u, '%\0')
            end
          }
          step.join(",")
        }.join(",")
      end

      def to_yus_privilege
        @directions.inject("org.oddb.model") { |yus, steps|
          steps = steps.dup
          yus << ".!" << steps.shift.to_s
          steps.inject(yus) { |yus, step| yus << "." << step.to_s }
        }
      end

      def +(other)
        dir = @directions.dup << [other].flatten
        Pointer.new(*dir)
      end

      def ==(other)
        eql?(other)
      end

      def hash
        to_s.hash
      end

      protected

      attr_reader :directions
    end

    class CreateItem
      attr_reader :pointer, :inner_pointer
      def initialize(pointer = Pointer.new)
        @inner_pointer = pointer
        @pointer = Pointer.new([:create, pointer])
        @data = {}
      end

      def structural_ancestors(app)
        @inner_pointer.ancestors.collect { |pointer| pointer.resolve(app) }
      end

      def append(val)
        @inner_pointer.append(val)
      end

      def carry(key, val = nil)
        @data.store(key.to_s.to_sym, val)
      end

      def method_missing(key, *args)
        @data[key]
      end

      def parent(app)
        @inner_pointer.parent.resolve(app)
      end

      def respond_to?(key, *args)
        key != :pointer_descr
      end
    end
  end
end
