#!/usr/bin/env ruby
require "state/setpass"
require "state/pharmacies/global"

module ODDB
  module State
    module Pharmacies
      class SetPass < State::Pharmacies::Global
        include State::SetPass
      end
    end
  end
end
