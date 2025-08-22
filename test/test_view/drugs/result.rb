#!/usr/bin/env ruby

# ODDB::View::Drugs::TestResult -- oddb.org -- 07.04.2011 -- mhatakeyama@ywesee.com

$: << File.expand_path("../..", File.dirname(__FILE__))
$: << File.expand_path("../../../src", File.dirname(__FILE__))

require "minitest/autorun"
require "flexmock/minitest"
require "view/drugs/result"
require "htmlgrid/select"

module ODDB
  module View
    module Drugs
      class TestDivExportCSV < Minitest::Test
        def setup
          @lnf = flexmock("lookandfeel",
            lookup: "lookup",
            attributes: {},
            resource_global: "resource_global",
            base_url: "base_url",
            _event_url: "_event_url")
          @session = flexmock("session",
            lookandfeel: @lnf,
            zone: "zone",
            persistent_user_input: "persistent_user_input")
          @model = flexmock("model")
          @form = ODDB::View::Drugs::DivExportCSV.new(@model, @session)
        end

        def test_init
          expected = {zone: "zone", search_query: "persistent_user_input", search_type: "persistent_user_input"}
          assert_equal(expected, @form.init)
        end
      end

      class TestEmptyResultComposite < Minitest::Test
        def test_title_none_found
          @lnf = flexmock("lookandfeel",
            lookup: "lookup",
            attributes: {},
            _event_url: "_event_url",
            disabled?: nil,
            base_url: "base_url")
          @session = flexmock("session",
            lookandfeel: @lnf,
            zone: "zone",
            persistent_user_input: "persistent_user_input",
            flavor: "flavor",
            event: "event",
            get_cookie_input: "get_cookie_input")
          @model = flexmock("model")
          @composite = ODDB::View::Drugs::EmptyResultComposite.new(@model, @session)
          assert_equal("lookup", @composite.title_none_found(@model, @session))
        end
      end

      class TestResultComposite < Minitest::Test
        def setup
          @lnf = flexmock("lookandfeel",
            enabled?: nil,
            disabled?: nil,
            lookup: "lookup",
            event_url: "event_url",
            _event_url: "_event_url",
            base_url: "base_url",
            attributes: {},
            result_list_components: {[1, 2] => :explain_patinfo},
            navigation: [],
            explain_result_components: {[1, 2] => :explain_patinfo})
          @session = flexmock("session",
            lookandfeel: @lnf,
            allowed?: nil,
            persistent_user_input: "persistent_user_input",
            zone: "zone",
            flavor: "flavor",
            event: "event",
            request_path: "request_path",
            get_cookie_input: "get_cookie_input")
          @model = flexmock([],
            package_count: "package_count")
          @composite = ODDB::View::Drugs::ResultComposite.new(@model, @session)
        end

        def test_init
          assert_equal({}, @composite.init)
        end

        def test_init__enabled
          flexmock(@lnf,
            enabled?: true,
            resource_global: "resource_global")
          assert_equal({}, @composite.init)
        end
      end
    end # Drugs
  end # View
end # ODDB
