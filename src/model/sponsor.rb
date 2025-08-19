#!/usr/bin/env ruby

# Sponsor -- oddb -- 29.07.2003 -- mhuggler@ywesee.com

require "date"
require "fileutils"
require "util/persistence"

module ODDB
  class Sponsor
    include Persistence
    ODBA_SERIALIZABLE = ["@logo_filenames", "@urls", "@emails"]
    attr_accessor :sponsor_until, :company, :urls, :emails
    attr_reader :logo_filenames
    def initialize
      super
      @logo_filenames = {}
    end

    def company_name
      @company.name if @company
    end
    alias_method :name, :company_name
    def logo_filename(language)
      @logo_filenames[language.to_sym]
    end

    def represents?(pac)
      pac.respond_to?(:company) && (pac.company == @company)
    end

    def url(language = "de")
      @urls.fetch(language.to_s, @urls["de"]) if @urls
    end

    def valid?
      @sponsor_until && @sponsor_until >= @@today
    end

    private

    def adjust_types(values, app = nil)
      values.each { |key, val|
        if val.is_a?(Pointer)
          values[key] = val.resolve(app)
        else
          case key
          when :company
            values[key] = if val.is_a? String
              app.company_by_name(val)
            elsif val.is_a?(Integer)
              app.company(val)
            end
          when :sponsor_until
            values[key] = val.is_a?(Date) ? val : nil
          end
        end
      }
    end
  end
end
