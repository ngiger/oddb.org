#!/usr/bin/env ruby

# ODDB::View::Interactions::TestResultList -- oddb.org -- 22.06.2011 -- mhatakeyama@ywesee.com

$: << File.expand_path("../../../src", File.dirname(__FILE__))

require "minitest/autorun"
require "flexmock/minitest"
require "view/interactions/resultlist"

module ODDB
  module View
    module Interactions
      class TestResultList < Minitest::Test
        def setup
          @lnf = flexmock("lookandfeel",
            lookup: "lookup",
            attributes: {},
            event_url: "event_url",
            _event_url: "_event_url")
          @sequence = flexmock("sequence", active_package_count: 0).by_default
          @model = flexmock("model",
            language: "language",
            oid: "oid",
            sequences: [@sequence])
          atc_class = flexmock("atc_class", code: "code")
          search_oddb = flexmock("search_oddb", atc_classes: [atc_class])
          @session = flexmock("session",
            lookandfeel: @lnf,
            language: "language",
            interaction_basket: [@model],
            interaction_basket_ids: "interaction_basket_ids",
            interaction_basket_link: "interaction_basket_link",
            interaction_basket_atc_codes: ["interaction_basket_atc_codes"],
            persistent_user_input: "persistent_user_input",
            search_oddb: search_oddb).by_default
          @list = ODDB::View::Interactions::ResultList.new([@model], @session)
        end

        def test_interaction_basket_status
          assert_kind_of(HtmlGrid::Link, @list.interaction_basket_status(@model, @session))
        end

        def test_name
          assert_equal("language", @list.name(@model, @session))
        end

        def test_name__else
          flexmock(@session, interaction_basket: [])
          assert_kind_of(HtmlGrid::Link, @list.name(@model, @session))
        end

        def test_search_oddb
          assert_nil(@list.search_oddb(@model, @session))
        end

        def test_search_oddb__active_sequeces_not_empty
          flexmock(@sequence, active_package_count: 1)
          flexmock(@model, name: "name")
          assert_kind_of(HtmlGrid::Link, @list.search_oddb(@model, @session))
        end
      end
    end # Interactions
  end # View
end # ODDB
