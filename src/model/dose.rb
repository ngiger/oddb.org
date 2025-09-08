#!/usr/bin/env ruby

# Dose -- oddb -- 02.03.2012 -- yasaka@ywesee.com
# Dose -- oddb -- 25.02.2003 -- hwyss@ywesee.com

require "util/quanty"

module ODDB
  class Dose < Quanty
    include Comparable
    alias_method :qty, :val
    DISABLE_DIFF = true
    def self.from_quanty(other)
      if other.is_a?(Dose)
        other
      elsif other.is_a?(Quanty)
        Dose.new(other.val, other.unit)
      else
        Dose.new(other)
      end
    end

    def initialize(qty, unit = nil)
      np = "-?[0-9]+(?:[.,][0-9]+)?" ## numerical pattern
      if (match = %r{(#{np})\s*-\s*(#{np})}u.match(qty.to_s))
        qty = round(match[1].to_f)..round(match[2].to_f)
      end
      if qty.is_a?(Range)
        qty_str = "#{qty.first}-#{qty.last}"
        qty = (qty.first + qty.last) / 2.0
        @not_normalized = [qty_str, unit].compact.join(" ")
      end
      if (match = %r{([^/]*)/\s*(#{np})\s*(.*)}u.match(unit.to_s.dup.force_encoding("utf-8")))
        qty_str = round(qty).to_s
        div = round(match[2])
        @not_normalized = [
          qty_str,
          [match[1].strip, div].join(" / "),
          match[3]
        ].join
        qty = qty.to_f / div.to_f
        unit = [match[1].strip, match[3].strip].join("/")
      end
      qty = round(qty)
      unit = unit.to_s.dup
      unit.tr!("L", "l")
      unit.gsub!(/U\.\s*Ph\.\s*Eur\./, "UPhEur")
      unit.delete!(".")
      unit.gsub!(/\s*\/\s*/, "/")
      unit.strip!
      fuzzy_retry = true
      strict_retry = true
      begin
        super
      rescue
        if fuzzy_retry
          unit = unit[0, 2]
          fuzzy_retry = false
          retry
        elsif strict_retry
          unit = ""
          strict_retry = false
          retry
        else
          raise
        end
      end
    end

    def scale
      if @not_normalized && str = @not_normalized[%r{/.*}u]
        Dose.new str[/[\d.]+/u], str[/\D+$/u]
      end
    rescue
    end

    def to_g
      if to_s.match?("mg")
        to_s.match(/[\d]+/u).to_s.to_i * 0.0001
      else
        to_i
      end
    end

    def to_f
      super
    rescue RuntimeError
      @val * @fact.factor
    end

    def to_i
      @val.to_i
    end

    def to_s
      @not_normalized or begin
        val = if @val.is_a? Float
          sprintf("%.5f", @val).gsub(/0+$/u, "")
        else
          @val
        end
        [val, @unit].join(" ")
      end
    end

    def want(unit)
      Dose.from_quanty(super)
    end

    def *(other)
      Dose.from_quanty(super)
    end

    def +(other)
      Dose.from_quanty(super)
    end

    def /(other)
      Dose.from_quanty(super)
    end

    def -(other)
      Dose.from_quanty(super)
    end

    def **(other)
      Dose.from_quanty(super)
    end

    def <=>(other)
      (@val * 1000).round <=> (adjust(other) * 1000).round
    rescue
      if @unit.nil?
        1
      elsif other.nil?
        -1
      elsif other.is_a?(Integer)
        if @unit.is_a?(Integer)
          @unit <=> other.unit
        else
          -1
        end
      elsif other.unit.nil?
        -1
      else
        @unit <=> other.unit
      end
    end

    private

    def round(qty)
      qty = qty.to_s.gsub(/'/u, "").tr(",", ".")
      if qty.to_f == qty.to_i
        qty.to_i
      else
        qty.to_f
      end
    end
  end

  module Drugs
    class Dose < ODDB::Dose; end
  end
end
