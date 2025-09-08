#!/usr/bin/env ruby

# ODDB::View::TestResultTemplate -- oddb.org -- 30.06.2011 -- mhatakeyama@ywesee.com

$: << File.expand_path("../../src", File.dirname(__FILE__))

require "minitest/autorun"
require "flexmock/minitest"
require "view/resulttemplate"

module ODDB
  class Session
    DEFAULT_FLAVOR = "gcc" unless defined?(DEFAULT_FLAVOR)
  end

  module View
    Copyright::ODDB_VERSION = "version" unless defined?(Copyright::ODDB_VERSION)
    class TestResultTemplate < Minitest::Test
      def stderr_null
        require "tempfile"
        $stderr = Tempfile.open("stderr")
        yield
        $stderr.close
        $stderr = STDERR
      end

      def replace_constant(constant, temp)
        stderr_null do
          keep = eval constant
          eval "#{constant} = temp"
          yield
          eval "#{constant} = keep"
        end
      end

      def setup
        @zones = flexmock("zones",
          sort_by: [])
        @navigation = flexmock("navigation",
          sort_by: [],
          empty?: false)
        @zone_navigation = flexmock("zone_navigation",
          sort_by: [],
          each_with_index: "each_with_index",
          empty?: false)
        @lnf = flexmock("lookandfeel",
          lookup: "lookup",
          enabled?: nil,
          attributes: {},
          resource: "resource",
          zones: @zones,
          disabled?: nil,
          _event_url: "_event_url",
          navigation: @zone_navigation,
          zone_navigation: @zone_navigation,
          direct_event: "direct_event")
        user = flexmock("user", valid?: nil)
        @zone = flexmock("zone", zone: "zone")
        @session = flexmock("session",
          state: @zone,
          lookandfeel: @lnf,
          flavor: Session::DEFAULT_FLAVOR,
          get_cookie_input: "get_cookie_input",
          user: user,
          sponsor: user,
          persistent_user_input: nil,
          request_path: "request_path",
          request_method: "GET")
        @model = flexmock("model")
        @content = flexmock("content", new: "new")
        replace_constant("ODDB::View::ResultTemplate::CONTENT", @content) do
          @template = ODDB::View::ResultTemplate.new(@model, @session)
        end
      end

      def test_init
        replace_constant("ODDB::View::ResultTemplate::CONTENT", @content) do
          assert_equal({}, @template.init)
        end
      end

      def test_init__enabled
        flexmock(@lnf,
          enabled?: true,
          languages: ["language"],
          language: "language",
          resource_localized: "resource_localized")
        state = flexmock("state", zone: "zone")
        flexmock(@session,
          state: state,
          request_path: "request_path")
        replace_constant("ODDB::View::ResultTemplate::CONTENT", @content) do
          assert_equal({}, @template.init)
        end
      end
    end
  end # View
end # ODDB
