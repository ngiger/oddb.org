#!/usr/bin/env ruby

# OrphanedPatinfo -- oddb -- 06.11.2003 -- rwaltert@ywesee.com

require "util/persistence"
require "util/language"

module ODDB
  class OrphanedTextInfo
    include Language
    attr_accessor :key
    alias_method :pointer_desc, :key
    def name
      if desc = descriptions.sort.first
        begin
          desc.last.name
        rescue
          $!.message
        end
      end
    end
  end

  class OrphanedFachinfo < OrphanedTextInfo
  end

  class OrphanedPatinfo < OrphanedTextInfo
  end
end
