#!/usr/bin/env ruby

# ODDB::State::Admin::TestIndications -- oddb.org -- 01.07.2011 -- mhatakeyama@ywesee.com

$: << File.expand_path("../../../src", File.dirname(__FILE__))

require "minitest/autorun"
require "flexmock/minitest"
require "state/admin/indications"

module ODDB
  module State
    module Admin
      class TestIndications < Minitest::Test
        def setup
          @lnf = flexmock("lookandfeel", lookup: "lookup")
          @session = flexmock("session",
            lookandfeel: @lnf,
            language: "language")
          @model = flexmock("model", size: 1)
          @state = ODDB::State::Admin::Indications.new(@session, @model)
        end

        def test_init
          assert_nil(@state.init)
        end

        def test_symbol
          assert_equal("language", @state.symbol)
        end
      end
    end # Admin
  end # State
end # ODDB
