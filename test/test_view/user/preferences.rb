#!/usr/bin/env ruby
$: << File.expand_path("../..", File.dirname(__FILE__))
$: << File.expand_path("../../../src", File.dirname(__FILE__))

require "minitest/autorun"
require "flexmock/minitest"
require "stub/cgi"
require "view/user/preferences"

module ODDB
  class Session
    DEFAULT_FLAVOR = "gcc" unless defined?(DEFAULT_FLAVOR)
  end

  module View
    class Copyright < HtmlGrid::Composite
      ODDB_VERSION = "oddb_version"
    end

    class StubForm
      def initialize(a, b, c)
      end
    end

    class StubPublicTemplate < PublicTemplate
      CONTENT = ODDB::View::StubForm
    end
  end
end

module ODDB
  module View
    class TestPreferences < Minitest::Test
      def test_prefs
        @lnf = flexmock("lookandfeel",
          lookup: "lookup",
          attributes: {},
          _event_url: "_event_url",
          enabled?: true,
          disabled?: true,
          flavor: "gcc",
          language: "de",
          resource_external: "resource_external",
          resource_localized: "resource_localized",
          resource_global: "resource_global",
          resource: "resource",
          base_url: "http://dummy.oddb.org",
          google_analytics_token: "google_analytics_token",
          direct_event: "direct_event")
        state = flexmock("state", zone: "zone",
          snapback_model: nil,
          direct_event: true)
        user = flexmock("user", valid?: true)

        @session = flexmock("session",
          lookandfeel: @lnf,
          zone: "zone",
          user_input: "user_input",
          request_path: "dummy.oddb.org/de/gcc/preferences/",
          state: state,
          get_cookie_input: "get_cookie_input",
          user: user,
          flavor: "gcc",
          valid_values: [:search_type],
          user_agent: "Mozilla",
          sponsor: nil,
          event: nil,
          persistent_user_input: nil)
        @view = ODDB::View::User::Preferences.new(@model, @session)
        result = @view.to_html(CGI.new)
        assert(result.index("composite"), "HTML should contain a composite")
      end
    end
  end # View
end # ODDB
