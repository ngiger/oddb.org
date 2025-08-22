#!/usr/bin/env ruby

# ODDB::View::Drugs::TestNarcotics -- oddb.org -- 09.11.2011 -- mhatakeyama@ywesee.com

$: << File.expand_path("../..", File.dirname(__FILE__))
$: << File.expand_path("../../../src", File.dirname(__FILE__))

require "minitest/autorun"
require "flexmock/minitest"
require "view/drugs/narcotics"

module ODDB
  module View
    module Drugs
      class TestNarcoticList < Minitest::Test
        def setup
          @lnf = flexmock("lookandfeel",
            lookup: "lookup",
            attributes: {},
            _event_url: "_event_url",
            result_list_components: ["result_list_components"],
            event_url: "event_url")
          state = flexmock("state",
            interval: "interval",
            intervals: "intervals")
          @session = flexmock("session",
            lookandfeel: @lnf,
            event: "event",
            state: state,
            direct_event: "direct_event",
            language: "language",
            flavor: "flavor")
          package = flexmock("package")
          narcotic = flexmock("narcotic",
            pointer: "pointer",
            category: "category",
            packages: [package],
            oid: "oid")
          @model = flexmock("model",
            narcotic: narcotic,
            language: "language")
          skip("Debug NarcoticsResultList later")
          @list = ODDB::View::Drugs::NarcoticsResultList.new([@model], @session)
        end

        def test_casrn
          assert_kind_of(ODDB::View::PointerLink, @list.casrn(@model, @session))
        end
      end

      class TestNarcoticsComposite < Minitest::Test
        def setup
          @lnf = flexmock("lookandfeel",
            lookup: "lookup",
            attributes: {},
            _event_url: "_event_url",
            navigation: [],
            disabled?: nil,
            enabled?: nil,
            base_url: "base_url",
            result_list_components: ["result_list_components"])
          state = flexmock("state",
            interval: "interval",
            intervals: "intervals")
          @session = flexmock("session",
            lookandfeel: @lnf,
            state: state,
            event: "event",
            direct_event: "direct_event",
            language: "language",
            zone: "zone",
            allowed?: true,
            persistent_user_input: ["persistent_user_input"],
            flavor: "flavor")
          package = flexmock("package")
          narcotic = flexmock("narcotic",
            pointer: "pointer",
            category: "category",
            packages: [package],
            oid: "oid")
          @model = flexmock("model",
            narcotic: narcotic,
            language: "language",
            empty?: nil)
          skip("Debug NarcoticsResultComposite later")
          @composite = ODDB::View::Drugs::NarcoticsResultComposite.new([@model], @session)
        end

        def test_title_narcotics
          assert_equal("lookup", @composite.title_narcotics(@model))
        end
      end
    end # Drugs
  end # View
end # ODDB
