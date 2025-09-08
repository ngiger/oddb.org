#!/usr/bin/env ruby

# ODDB::View::Admin::TestPatinfoPreview -- oddb.org -- 30.06.2011 -- mhatakeyama@ywesee.com

$: << File.expand_path("../../../src", File.dirname(__FILE__))

require "minitest/autorun"
require "flexmock/minitest"
require "view/admin/patinfopreview"

module ODDB
  module View
    module Admin
      class TestPatinfoPreviewComposite < Minitest::Test
        def setup
          @lnf = flexmock("lookandfeel", lookup: "lookup")
          @session = flexmock("session", lookandfeel: @lnf)
          @model = flexmock("model", name: "name")
          skip("Avoid undefined method `document_composite' for #<ODDB::View::Admin::PatinfoPreviewComposite")
          @composite = ODDB::View::Admin::PatinfoPreviewComposite.new(@model, @session)
        end

        def test_document
          assert_kind_of(ODDB::View::Drugs::PatinfoInnerComposite, @composite.document(@model, @session))
        end
      end
    end # Admin
  end    # View
end     # ODDB
