#!/usr/bin/env ruby

# ODDB::View::TestTabNavigationLink -- oddb.org -- 05.07.2011 -- mhatakeyama@ywesee.com

$: << File.expand_path("../../src", File.dirname(__FILE__))

require "minitest/autorun"
require "flexmock/minitest"
require "view/tab_navigationlink"

module ODDB
  module View
    class TestTabNavigationLink < Minitest::Test
      def setup
        @lnf = flexmock("lookandfeel",
          lookup: "lookup",
          attributes: {},
          _event_url: "_event_url")
        @session = flexmock("session",
          lookandfeel: @lnf,
          zone: "zone")
        @model = flexmock("model")
        @view = ODDB::View::TabNavigationLink.new("name", @model, @session)
      end

      def test_init
        assert_equal("_event_url", @view.init)
      end
    end
  end # View
end # ODDB
