#!/usr/bin/env ruby

# ODDB::State::Drugs::TestVaccines -- oddb.org -- 01.07.2011 -- mhatakeyama@ywesee.com

$: << File.expand_path("../../../src", File.dirname(__FILE__))

require "minitest/autorun"
require "flexmock/minitest"
require "state/global"
require "state/drugs/vaccines"

module ODDB
  module State
    module Drugs
      class TestVaccines < Minitest::Test
        def setup
          @lnf = flexmock("lookandfeel", lookup: "lookup")
          @session = flexmock("session",
            lookandfeel: @lnf,
            persistent_user_input: "persistent_user_input")
          @model = flexmock("model")
          flexmock(ODBA.cache, index_keys: [])
          @state = ODDB::State::Drugs::Vaccines.new(@session, @model)
        end

        def test_vaccines
          assert_equal(@state, @state.vaccines)
        end

        def test_vaccines__else
          @state.instance_eval('@range = "range"', __FILE__, __LINE__)
          assert_kind_of(ODDB::State::Drugs::Vaccines, @state.vaccines)
        end
      end
    end # Drugs
  end # State
end # ODDB
