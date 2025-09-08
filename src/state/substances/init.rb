#!/usr/bin/env ruby

# State::Substances::Init -- oddb -- 23.08.2004 -- mhuggler@ywesee.com

require "view/substances/search"

module ODDB
  module State
    module Substances
      class Init < State::Substances::Global
        VIEW = View::Substances::Search
        DIRECT_EVENT = :home_substances
      end
    end
  end
end
