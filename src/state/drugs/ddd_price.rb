#!/usr/bin/env ruby

# ODDB::State::Drugs::DDDPrice -- oddb.org -- 19.01.2012 -- mhatakeyama@ywesee.com
# ODDB::State::Drugs::DDDPrice -- oddb.org -- 10.04.2006 -- hwyss@ywesee.com

require "state/drugs/global"
require "view/drugs/ddd_price"

module ODDB
  module State
    module Drugs
      class DDDPrice < Global
        LIMITED = true
        VIEW = View::Drugs::DDDPrice
        def init
          super
          reg = @session.user_input(:reg)
          seq = @session.user_input(:seq)
          pac = @session.user_input(:pack)
          @model = if reg = @session.app.registration(reg) and seq = reg.sequence(seq)
            seq.package(pac)
          end

          unless @model
            @default_view = ODDB::View::Drugs::EmptyResult
          end
        end
      end
    end
  end
end
