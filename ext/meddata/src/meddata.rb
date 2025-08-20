# MedData -- oddb -- 26.11.2004 -- jlang@ywesee.com

$: << File.expand_path("../../../src", File.dirname(__FILE__))
$: << File.dirname(__FILE__)

require "drbsession"
require "meddparser"
require "result"

module ODDB
  module MedData
    class OverflowError < RuntimeError; end

    def self.session(search_type = :partner, &block)
      yield(DRbSession.new(search_type))
    end
  end
end
