#!/usr/bin/env ruby

# ODDB::Fachinfo -- oddb.org -- 14.08.2012 -- yasaka@ywesee.com
# ODDB::Fachinfo -- oddb.org -- 24.10.2011 -- mhatakeyama@ywesee.com
# ODDB::Fachinfo -- oddb.org -- 12.09.2003 -- rwaltert@ywesee.com

require "flickraw"
require "util/persistence"
require "util/language"
require "util/searchterms"
require "model/registration_observer"
require "diffy"
require "util/today"

module ODDB
  class Fachinfo
    class ChangeLogItem  # we cannot remove this class or loading the ODBA cache will fail!
    end
    attr_accessor :links
    include Persistence
    include Language
    include RegistrationObserver
    def article_codes(expired = true)
      codes = []
      @registrations.collect { |reg|
        next unless reg.fachinfo == self # invalid reference
        if !expired
          next unless reg.public? and reg.has_fachinfo?
        end
        reg.each_package { |pac|
          cds = {
            article_ean13: pac.barcode.to_s
          }
          if (pcode = pac.pharmacode)
            cds.store(:article_pcode, pcode)
          end
          if (psize = pac.size)
            cds.store(:article_size, psize)
          end
          if (pdose = pac.dose)
            cds.store(:article_dose, pdose.to_s)
          end
          codes.push(cds)
        }
      }
      codes
    end

    def links
      @links ||= []
      @links.compact.sort_by { |link| link.created }.reverse
    end

    def atc_class
      if (reg = @registrations.first)
        reg.atc_classes.first
      end
    end

    def company
      if (reg = @registrations.first)
        reg.company
      end
    end

    def company_name
      if (reg = @registrations.first)
        reg.company_name
      end
    end

    def generic_type
      @registrations.each { |reg|
        if (type = reg.generic_type)
          return type
        end
      }
      :unknown
    end

    def localized_name(language = :de)
      name = ""
      if (doc = send(language)) && doc.respond_to?(:name)
        name = doc.name.to_s
      end
      name = name_base if name.empty?
      name
    end

    def name_base
      if (reg = @registrations.first)
        reg.name_base
      end
    end

    def pointer_descr
      name_base
    end

    def search_text(language)
      ODDB.search_term(send(language).indications.to_s)
    end

    def interaction_text(language)
      ODDB.search_term(send(language).interactions.to_s)
    end

    def substance_names
      @registrations.collect { |reg|
        reg.substance_names
      }.flatten.uniq
    end

    def unwanted_effect_text(language)
      ODDB.search_term(send(language).unwanted_effects.to_s)
    end

    def has_photo?
      registrations.each do |reg|
        reg.packages.each do |pack|
          if pack.has_flickr_photo?
            return true
          end
        end
      end
      false
    end

    def photos(image_size = "Thumbnail")
      image_size.capitalize!
      photos = []
      threads = {}
      mutex = Mutex.new
      registrations.each do |reg|
        reg.packages.each do |pack|
          if id = pack.flickr_photo_id
            unless threads.keys.include?(id)
              threads[id] = Thread.new do
                mutex.synchronize do
                  # if empty hash is returned, something error may be happened
                  photo = pack.photo(image_size)
                  photos << photo if photo && !photo.empty?
                end
              end
            end
          end
        end
      end
      threads.values.each do |thread|
        thread.join
      end
      return nil if photos.empty? # return valid hash or nil
      photos.sort do |a, b| # sort_by size in name
        result = a[:name].gsub(/(\d+)/) { "%04d" % $1.to_i } <=>
          b[:name].gsub(/(\d+)/) { "%04d" % $1.to_i }
        if result.zero?
          result = a[:name] <=> b[:name]
          if result.zero?
            result = a[:url] <=> b[:url]
          end
        end
        result
      end
    end
  end

  class FachinfoDocument
    include Persistence
    attr_accessor :change_log
    def pointer_descr
      "Fachinfo"
    end
    class ChangeLogItem
      include Persistence
      attr_accessor :time, :diff
      def <=>(other)
        # [diff.to_s, time] <=> [anOther.diff.to_s, anOther.time]
        diff.to_s <=> other.diff.to_s
      end

      def pointer_descr
        time.strftime("%d.%m.%Y")
      end
    end
    Fachinfo_diff_options = {diff: "-U 3",
                             source: "strings",
                             include_plus_and_minus_in_html: true,
                             include_diff_info: false,
                             context: 0,
                             allow_empty_diff: false}
    def add_change_log_item(old_text, new_text, date = @@today, options = Fachinfo_diff_options)
      @change_log ||= []
      item = ChangeLogItem.new
      item.time = date
      item.diff = Diffy::Diff.new(old_text ? old_text.to_s : "", new_text.to_s, options)
      begin
        if @change_log and @change_log.find { |x| x.diff.to_s.eql?(item.diff.to_s) }
          puts "FachinfoDocument::ChangeLogItem: Don't add duplicated entry #{old_text ? old_text.split("\n")[0..2] : ""}"
          return
        end
      rescue => error
        puts "FachinfoDocument::ChangeLogItem: Error #{error} for #{old_text ? old_text.split("\n")[0..2] : ""}"
      end
      already_disabled = GC.disable
      @change_log.push(item)
      odba_store
      GC.enable unless already_disabled
    end

    def change_log
      @change_log ||= []
    end
    attr_accessor :name, :galenic_form, :composition
    attr_accessor :effects, :kinetic, :indications, :usage
    attr_accessor :restrictions, :unwanted_effects
    attr_accessor :interactions, :overdose, :other_advice
    attr_accessor :date, :iksnrs, :reference, :packages
    attr_accessor :delivery, :distribution, :fabrication, :atc_code
    attr_reader :CHAPTERS
    CHAPTERS = [
      :galenic_form,
      :composition,
      :effects,
      :kinetic,
      :indications,
      :usage,
      :restrictions,
      :unwanted_effects,
      :interactions,
      :overdose,
      :other_advice,
      :delivery,
      :distribution,
      :fabrication,
      # :reference,
      :iksnrs,
      :packages,
      :date
    ]

    def empty?
    end

    def chapter_names
      chapters.select { |chapter|
        respond_to?(chapter) && send(chapter)
      }
    end

    def chapters
      self.class::CHAPTERS
    end

    def each_chapter(&block)
      chapter_names.each { |chap|
        if (chapter = send(chap))
          block.call(chapter)
        end
      }
    end

    def first_chapter
      chapter = nil
      chapters.find { |chapter|
        respond_to?(chapter) && send(chapter)
      }
      chapter
    end

    def text
      string = ""
      each_chapter { |chap| string << chap.to_s + "\n" }
      string
    end
  end

  class FachinfoDocument2001 < FachinfoDocument
    attr_accessor	:contra_indications, :pregnancy
    attr_accessor	:driving_ability, :preclinic
    attr_accessor	:registration_owner, :amzv
    CHAPTERS = [
      :amzv,
      :composition,
      :galenic_form,
      :indications,
      :usage,
      :contra_indications,
      :restrictions,
      :interactions,
      :pregnancy,
      :driving_ability,
      :unwanted_effects,
      :overdose,
      :effects,
      :kinetic,
      :preclinic,
      :other_advice,
      :iksnrs,
      :packages,
      :registration_owner,
      :date
    ]
  end

  class PseudoFachinfoDocument < FachinfoDocument
    attr_accessor :contra_indications, :distributor, :name, :lang
    CHAPTERS = [
      :composition,
      :indications,
      :usage,
      :contra_indications,
      :restrictions,
      :interactions,
      :unwanted_effects,
      :effects,
      :other_advice,
      :iksnrs,
      :packages,
      :fabrication,
      :distributor,
      :date
    ]
  end

  class FachinfoLink
    attr_accessor :name, :url, :created
    def initialize
      @name = ""
      @url = "http://"
      @created = Time.now.to_s
    end
  end
end
