#!/usr/bin/env ruby

# ODDB::View::TestLogoHead -- oddb.org -- 21.06.2011 -- mhatakeyama@ywesee.com

$: << File.expand_path("../../src", File.dirname(__FILE__))

require "minitest/autorun"
require "flexmock/minitest"
require "view/logohead"
require "htmlgrid/span"

module ODDB
  module View
    module SponsorDisplay
      class StubSponsorDisplay
        include ODDB::View::SponsorDisplay
        def initialize(model, session)
          @model = model
          @session = session
          @lookandfeel = session.lookandfeel
        end

        def sponsor(model, session)
          session.sponsor
        end
      end

      class TestSponsorDisplay < Minitest::Test
        def test_sponsor__sponsor_valid
          user = flexmock("user", valid?: nil)
          lnf = flexmock("lookandfeel",
            enabled?: true,
            language: "language",
            lookup: "lookup",
            format_date: "format_date",
            resource_global: "resource_global")
          session = flexmock("session",
            lookandfeel: lnf,
            user: user,
            sponsor: "sponsor")
          model = flexmock("model")
          @view = ODDB::View::SponsorDisplay::StubSponsorDisplay.new(model, session)
          assert_equal("sponsor", @view.sponsor(model, session))
        end

        def test_sponsor__sponsor_invalid
          user = flexmock("user", valid?: nil)
          lnf = flexmock("lookandfeel", enabled?: true)
          session = flexmock("session",
            lookandfeel: lnf,
            user: user,
            sponsor: nil)
          model = flexmock("model")
          @view = ODDB::View::SponsorDisplay::StubSponsorDisplay.new(model, session)
          assert_nil(@view.sponsor(model, session))
        end
      end
    end # SponsorDisplay
  end # View
end # ODDB
