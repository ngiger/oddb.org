#!/usr/bin/env ruby

# ODDB::TestSlate -- oddb.org -- 01.07.2011 -- mhatakeyama@ywesee.com

$: << File.expand_path("../../src", File.dirname(__FILE__))

require "minitest/autorun"
require "flexmock/minitest"
require "model/slate"

module ODDB
  class TestSlate < Minitest::Test
    def setup
      @model = ODDB::Slate.new("name")
    end

    def test_create_item
      flexmock(ODBA.cache, next_id: 123)
      assert_kind_of(ODDB::InvoiceItem, @model.create_item)
    end

    def test_item
      flexmock(ODBA.cache, next_id: 123)
      @model.create_item
      assert_kind_of(ODDB::InvoiceItem, @model.item(123))
    end
  end
end # ODDB
