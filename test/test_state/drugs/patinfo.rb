#!/usr/bin/env ruby

# ODDB::State::Drugs::TestPatinfo -- oddb.org -- 01.07.2011 -- mhatakeyama@ywesee.com

$: << File.expand_path("../../../src", File.dirname(__FILE__))

require "minitest/autorun"
require "flexmock/minitest"
require "state/drugs/patinfo"

module ODDB
  module State
    module Drugs
      class TestPatinfo < Minitest::Test
        def setup
          @lnf = flexmock("lookandfeel", lookup: "lookup")
          @session = flexmock("session", lookandfeel: @lnf)
          @model = flexmock("model", name_base: "name_base")
          @state = ODDB::State::Drugs::Patinfo.new(@session, @model)
        end

        def test_init
          assert_equal("lookup", @state.init)
        end
      end
    end # Drugs
  end # State
end # ODDB
