#!/usr/bin/env ruby

# ODDB::View::Admin::TestWaitForFachinfo -- oddb.org -- 28.06.2011 -- mhatakeyama@ywesee.com

$: << File.expand_path("../../../src", File.dirname(__FILE__))

require "minitest/autorun"
require "flexmock/minitest"
require "view/admin/wait_for_fachinfo"

module ODDB
  module View
    class Session
      DEFAULT_FLAVOR = "gcc" unless defined?(DEFAULT_FLAVOR)
    end

    module Admin
      class TestStatusBar < Minitest::Test
        def setup
          @lnf = flexmock("lookandfeel", lookup: "lookup")
          state = flexmock("state", wait_counter: 0)
          @session = flexmock("session",
            lookandfeel: @lnf,
            state: state)
          @model = flexmock("model")
          @composite = ODDB::View::Admin::StatusBar.new(@model, @session)
        end

        def test_init
          assert_equal("20", @composite.init)
        end
      end

      class TestWaitForFachinfo < Minitest::Test
        def setup
          @lnf = flexmock("lookandfeel",
            lookup: "lookup",
            attributes: {},
            enabled?: nil,
            disabled?: false,
            zones: {},
            resource: "resource",
            event_url: "event_url")
          user = flexmock("user", valid?: nil)
          sponsor = flexmock("sponsor", valid?: nil)
          state = flexmock("state", wait_counter: 0)
          @session = flexmock("session",
            lookandfeel: @lnf,
            user: user,
            sponsor: sponsor,
            state: state,
            flavor: "flavor",
            request_path: "request_path",
            request_method: "GET",
            persistent_user_input: nil)
          @model = flexmock("model")
          @view = ODDB::View::Admin::WaitForFachinfo.new(@model, @session)
        end

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

        def test_http_headers
          replace_constant("ODDB::View::PublicTemplate::HTTP_HEADERS", {}) do
            expected = {"Refresh" => "5; url=event_url"}
            assert_equal(expected, @view.http_headers)
          end
        end
      end
    end # Admin
  end # View
end # ODDB
