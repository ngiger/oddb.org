#!/usr/bin/env ruby
# encoding: utf-8
# State::Drugs::Limit -- oddb -- 28.10.2005 -- hwyss@ywesee.com

require 'state/limit'

module ODDB
	module State
		module Migel
class Limit < Global
	include State::Limit
end
		end
	end
end
