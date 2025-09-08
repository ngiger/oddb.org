#!/usr/bin/env ruby

# ODDB::State::Substances::TestSelectSubstance -- oddb.org -- 29.06.2011 -- mhatakeyama@ywesee.com

$: << File.expand_path("../../../src", File.dirname(__FILE__))

require "minitest/autorun"
require "flexmock/minitest"
require "htmlgrid/inputradio"
require "view/search"
require "state/substances/selectsubstance"

module ODDB
  module State
    module Substances
      class TestSelectSubstance < Minitest::Test
        def setup
          @app = flexmock("app", merge_substances: "merge_substances")
          @lnf = flexmock("lookandfeel", lookup: "lookup")
          pointer = flexmock("pointer", resolve: "target")
          @session = flexmock("session",
            app: @app,
            lookandfeel: @lnf,
            user_input: pointer).by_default
          source = flexmock("source", pointer: "pointer")
          @model = flexmock("model", source: source).by_default
          @state = ODDB::State::Substances::SelectSubstance.new(@session, @model)
        end

        def test_merge
          assert_kind_of(ODDB::State::Substances::Substance, @state.merge)
        end

        def test_merge__e_selfmerge_substance
          flexmock(@model, source: "target")
          assert_equal(@state, @state.merge)
        end

        def test_merge__e_unknown_substance
          flexmock(@session, user_input: nil)
          assert_equal(@state, @state.merge)
        end
      end
    end # Substances
  end # State
end # ODDB
