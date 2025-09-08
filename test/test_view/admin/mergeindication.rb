#!/usr/bin/env ruby

# ODDB::View::Admin::TestMergeIndication -- oddb.org -- 28.06.2011 -- mhatakeyama@ywesee.com

$: << File.expand_path("../../../src", File.dirname(__FILE__))

require "minitest/autorun"
require "flexmock/minitest"
require "htmlgrid/errormessage"
require "view/admin/mergeindication"

module ODDB
  module View
    module Admin
      class TestMergeIndicationForm < Minitest::Test
        def setup
          @lnf = flexmock("lookandfeel",
            lookup: "lookup",
            language: "language",
            attributes: {},
            base_url: "base_url")
          @session = flexmock("session",
            lookandfeel: @lnf,
            warning?: nil,
            error?: nil)
          @model = flexmock("model", description: "description")
          @form = ODDB::View::Admin::MergeIndicationForm.new(@model, @session)
        end

        def test_init
          assert_nil(@form.init)
        end
      end

      class TestMergeIndicationComposite < Minitest::Test
        def setup
          @lnf = flexmock("lookandfeel",
            lookup: "lookup",
            language: "language",
            attributes: {},
            base_url: "base_url")
          @session = flexmock("session",
            lookandfeel: @lnf,
            warning?: nil,
            error?: nil)
          @model = flexmock("model",
            registration_count: 0,
            description: "description")
          @composite = ODDB::View::Admin::MergeIndicationComposite.new(@model, @session)
        end

        def test_merge_indication
          assert_equal("lookup", @composite.merge_indication(@model, @session))
        end
      end
    end # Admin
  end # View
end # ODDB
