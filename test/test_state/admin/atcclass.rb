#!/usr/bin/env ruby

# ODDB::State::Admin::TestAtcClass -- oddb.org -- 01.07.2011 -- mhatakeyama@ywesee.com

$: << File.expand_path("../../../src", File.dirname(__FILE__))

require "minitest/autorun"
require "flexmock/minitest"
require "state/admin/atcclass"

module ODDB
  module State
    module Admin
      class TestAtcClass < Minitest::Test
        def setup
          @app = flexmock("app", update: "update")
          @lnf = flexmock("lookandfeel",
            lookup: "lookup",
            languages: ["language"])
          @session = flexmock("session",
            app: @app,
            lookandfeel: @lnf,
            user_input: "user_input")
          @model = flexmock("model", pointer: "pointer")
          @state = ODDB::State::Admin::AtcClass.new(@session, @model)
          flexmock(@state, unique_email: "unique_email")
        end

        def test_init
          assert_nil(@state.init)
        end

        def test_update
          assert_equal(@state, @state.update)
        end
      end
    end # Admin
  end # State
end # ODDB
