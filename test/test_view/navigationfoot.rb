#!/usr/bin/env ruby

# ODDB::View::TestNavigationFoot -- oddb.org -- 20.06.2011 -- mhatakeyama@ywesee.com
# ODDB::View::TestNavigationFoot -- oddb.org -- 20.11.2002 -- hwyss@ywesee.com

$: << File.expand_path("..", File.dirname(__FILE__))
$: << File.expand_path("../../src", File.dirname(__FILE__))

require "minitest/autorun"
require "flexmock/minitest"
require "stub/session"
require "view/navigationfoot"
require "custom/lookandfeelbase"
require "util/validator"
require "sbsm/state"
require "stub/cgi"

module ODDB
  ODDB_VERSION = "version"
  class GalenicGroup
    def self.reset_oid
      @oid = 0
    end
  end

  module View
    class StubFooState < SBSM::State
      DIRECT_EVENT = :foo
    end

    class StubBarState < SBSM::State
      DIRECT_EVENT = :bar
    end

    class StubBazState < SBSM::State
      DIRECT_EVENT = :baz
    end

    class TestNavigationFoot < Minitest::Test
      class StubLookandfeel < LookandfeelBase
        attr_accessor :zone_navigation
        DICTIONARIES = {
          "de"	=>	{
            foo: "Foo",
            bar: "Bar",
            baz: "Baz",
            date_format: "%d.%m.%Y",
            navigation_divider: "&nbsp;|&nbsp;"
          }
        }
        def direct_event
          :foo
        end

        attr_writer :zone_navigation

        def event_url(event)
          "/de/gcc/#{event}"
        end

        def navigation
          [StubFooState, StubBarState, StubBazState]
        end
      end

      class StubApp
        attr_accessor :last_update, :lookandfeel
        def unknown_user
          "unknown_user"
        end
      end

      def setup
        GalenicGroup.reset_oid
        @app = StubApp.new
        @app.last_update = Time.now
        @session = ODDB::Session.new(app: @app)
        @session.lookandfeel = StubLookandfeel.new(@session)
        skip("Under Rack it is too difficult to test it this way")
        @view = View::NavigationFoot.new(nil, @session)
      end

      def test_to_html
        result = ""
        result << @view.to_html(CGI.new)
        expected = [
          '<TABLE cellspacing="0" class="navigation">',
          '<TD><A class="navigation right" name="foo">Foo</A></TD>',
          "<TD>&nbsp;|&nbsp;</TD>",
          '<TD><A class="subheading" href="http://test.oddb.org/de/gcc/bar/" name="bar">Bar</A>',
          '<TD>&nbsp;|&nbsp;</TD><TD><A class="subheading" href="http://test.oddb.org/de/gcc/baz/" name="baz">Baz</A></TD>'
        ]
        expected.each { |line|
          assert(result.index(line), "expected #{line} in \n#{result}")
        }
      end
    end
  end
end

module ODDB
  module View
    class TestNavigationFoot2 < Minitest::Test
      def setup
        @navigation = flexmock("navigation",
          sort_by: [],
          empty?: false,
          each_with_index: "each_with_index")
        @zone_navigation = flexmock("zone_navigation",
          sort_by: [],
          each_with_index: "each_with_index",
          empty?: false)
        @lnf = flexmock("lookandfeel",
          lookup: "lookup",
          disabled?: nil,
          enabled?: nil,
          zone_navigation: @zone_navigation,
          attributes: {},
          direct_event: "direct_event",
          _event_url: "_event_url",
          navigation: @navigation)
        @session = flexmock("session", lookandfeel: @lnf, user: nil)
        @model = flexmock("model")
        @composite = ODDB::View::NavigationFoot.new(@model, @session)
      end

      def test_init
        expected = {
          [0, 0] => "navigation",
          [1, 1] => "subheading right",
          [1, 0] => "navigation right",
          [0, 1] => "subheading"
        }
        assert_equal(expected, @composite.init)
      end

      def test_init__navigation
        @lnf = flexmock("lookandfeel",
          lookup: "lookup",
          disabled?: true,
          enabled?: nil,
          zone_navigation: @zone_navigation,
          attributes: {},
          direct_event: "direct_event",
          _event_url: "_event_url",
          navigation: @navigation)
        @session = flexmock("session", lookandfeel: @lnf)
        @composite = ODDB::View::NavigationFoot.new(@model, @session)
        expected = {[0, 0] => "subheading"}
        assert_equal(expected, @composite.init)
      end

      def test_init__zone_navigation
        flexmock(@lnf) do |lnf|
          lnf.should_receive(:disabled?).with(:navigation).and_return(false)
          lnf.should_receive(:disabled?).with(:zone_navigation).and_return(true)
        end
        expected = {[0, 0] => "navigation", [1, 0] => "navigation right", [0, 1] => "subheading", [1, 1] => "subheading right"}
        assert_equal(expected, @composite.init)
      end

      def test_init__custom_navigation
        @lnf = flexmock("lookandfeel",
          lookup: "lookup",
          enabled?: true,
          zone_navigation: @zone_navigation,
          attributes: {},
          direct_event: "direct_event",
          _event_url: "_event_url",
          navigation: @navigation)
        @lnf.should_receive(:disabled?).with(:navigation).and_return(false)
        @lnf.should_receive(:disabled?).with(:zone_navigation).and_return(false)
        expected = {[0, 0] => "subheading", [1, 0] => "subheading right"}
        @session = flexmock("session", lookandfeel: @lnf)
        @composite = ODDB::View::NavigationFoot.new(@model, @session)
        assert_equal(expected, @composite.init)
      end
    end
  end # View
end # ODDB
