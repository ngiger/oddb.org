#!/usr/bin/env ruby

# ODDB::State::Drugs::TestDDDPrice -- oddb.org -- 09.11.2011 -- mhatakeyama@ywesee.com

$: << File.expand_path("../../../src", File.dirname(__FILE__))

require "minitest/autorun"
require "flexmock/minitest"
require "view/drugs/compare"
require "state/drugs/ddd_price"

module ODDB
  module State
    module Drugs
      class TestDDDPrice < Minitest::Test
        def setup
          registration = flexmock("registration", sequence: nil)
          @app = flexmock("app", registration: registration)
          @lnf = flexmock("lookandfeel", lookup: "lookup")
          @model = flexmock("model")
          pointer = flexmock("pointer",
            resolve: @model,
            is_a?: true)
          @session = flexmock("session",
            app: @app,
            lookandfeel: @lnf,
            user_input: {"x" => pointer}).by_default
          @state = ODDB::State::Drugs::DDDPrice.new(@session, @model)
        end

        def test_init
          assert_equal(ODDB::View::Drugs::EmptyResult, @state.init)
        end

        def test_init__nil
          flexmock(@session, user_input: {})
          assert_equal(ODDB::View::Drugs::EmptyResult, @state.init)
        end
      end
    end # Drugs
  end # State
end # ODDB
