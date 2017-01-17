#!/usr/bin/env ruby
# encoding: utf-8
# Dose -- oddb -- 02.03.2012 -- yasaka@ywesee.com
# Dose -- oddb -- 25.02.2003 -- hwyss@ywesee.com 

require 'ruby-units'

RubyUnits.configure do |config|
  config.separator = true
end

RubyUnits::Unit.define('IE') do |i_e|
  i_e.definition  = RubyUnits::Unit.new(1)
  i_e.aliases      = %w(I.E.)
end
RubyUnits::Unit.define('UI') do |i_e|
  i_e.definition  = RubyUnits::Unit.new(1)
  i_e.aliases      = %w(U.I.)
end
RubyUnits::Unit.define('Tabletten') do |i_e|
  i_e.definition  = RubyUnits::Unit.new(1)
  i_e.aliases      = %w(Tabletten Sachet Sachets Sachet(s))
end

ie1 = Unit.new('1 IE')
ui1 = Unit.new('1 UI')
# ie1 = Unit.new('3 Tabletten')
# ie1 = Unit.new('1 Sachet')
# ie1 = Unit.new('3 Sachets')
# ie1 = Unit.new('3 Sachet(s)')
Quanty = Unit
class Quanty
  class Fact < Hash
  end
  require 'pry'
  def marshal_load a
    binding.pry
  end
end

module ODDB
  class Dose < Quanty
    attr_reader :val
    attr_reader :unit
    attr_reader :fact
    alias value val
    alias :qty :val
    def initialize(*args)
      @scalar      = nil
      @base_scalar = nil
      @unit_name   = nil
      @signature   = nil
      @output      = {}
      args.each{|arg| arg.sub!('(s)','s') if arg.is_a?(String);}
      args.compact == [] ? super(0) : super(*args)
    end
    def unit
      puts "Dose.unit #{@unit.inspect}"
      @unit ? @unit : self.units
    end
    def qty
      @val ? @val : self.scalar
    end
#    def unit
#      self.units
#    end
    def <=>(other)
      other ? Unit.new(self.to_s) <=> Unit.new(other.to_s) : Unit.new(self.to_s) <=> nil
    end
    def ==(other)
      other ? Unit.new(self.to_s) == Unit.new(other.to_s) : nil
    end
    def to_f
      self.scalar.to_f
    end
    def to_i
      super
    rescue => e
      puts "Dose.to_i: rescue e #{e} #{qty}/#{units} fact: #{fact} val: #{val}"
      # require 'pry'; binding.pry
      0
    end
    def to_s
      super
    rescue => e
      # require 'pry'; binding.pry
      puts "Dose.to_s: rescue e #{e} #{qty}/#{units} fact: #{fact} val: #{val}"
      '1'
    end
    def to_g
      self.convert_to('g').scalar
    end
    def Dose.from_quanty(other)
      if other.is_a?(Dose)
        other
      else
        Dose.new(other.to_s)
      end
    end
    def scale
      return nil unless units != ''
      denominator.join('').gsub(/[<>]/,'')
    end
    def want(unit)
      Dose.new(Dose.from_quanty(to_s).convert_to(unit).to_s)
    end
    def /(other)  # here we want to return a number if both doses are compatible/
      if self.compatible?(other)
        self.base_scalar / other.base_scalar
      elsif other.is_a?(Numeric)
        super(other)
      end
    end
    def self.quanty_to_ruby_units(object)
      if object.is_a?(Dose) && object.old_format
        puts "Convert old to val #{object.val} u #{object.unit}"
        Dose.new(object.val, object.unit)
      else
        object
      end
    rescue => e
      require 'pry'; binding.pry
    end
    def old_format
      defined?(@val) && @val
    end
  end
  module Drugs
    class Dose < ODDB::Dose; end
  end
end
