#!/usr/bin/env ruby

# State::User::Limit -- oddb -- 26.07.2005 -- hwyss@ywesee.com

require "state/limit"

module ODDB
  module State
    module User
      class Limit < Global
        include State::Limit
      end
    end
  end
end
