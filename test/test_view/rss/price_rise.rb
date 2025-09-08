#!/usr/bin/env ruby

# ODDB::View::Rss::TestPriceRise -- oddb.org -- 05.07.2011 -- mhatakeyama@ywesee.com

$: << File.expand_path("../../../src", File.dirname(__FILE__))

require "minitest/autorun"
require "flexmock/minitest"
require "view/rss/package"
require "view/rss/price_rise"

module ODDB
  module View
    module Rss
      class TestPriceRise < Minitest::Test
        def setup
          @lnf = flexmock("lookandfeel", lookup: "lookup")
          @session = flexmock("session", lookandfeel: @lnf)
          @model = flexmock("model")
          @view = ODDB::View::Rss::PriceRise.new(@model, @session)
        end

        def test_init
          assert_nil(@view.init)
        end
      end
    end # Interactions
  end # View
end # ODDB
