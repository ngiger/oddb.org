#!/usr/bin/env ruby

# ODDB::View::Admin::TestPasswordLost -- oddb.org -- 29.06.2011 -- mhatakeyama@ywesee.com

$: << File.expand_path("../../../src", File.dirname(__FILE__))

require "minitest/autorun"
require "flexmock/minitest"
require "view/admin/password_lost"

module ODDB
  module View
    module Admin
      class TestPasswordLostComposite < Minitest::Test
        def setup
          @lnf = flexmock("lookandfeel",
            lookup: "lookup",
            attributes: {},
            base_url: "base_url")
          @session = flexmock("session",
            lookandfeel: @lnf,
            error: "error",
            warning?: nil,
            error?: nil)
          @model = flexmock("model")
          @composite = ODDB::View::Admin::PasswordLostComposite.new(@model, @session)
        end

        def test_init
          assert_nil(@composite.init)
        end
      end
    end # Admin
  end # View
end # ODDB
