#!/usr/bin/env ruby

# ODDB::TestOrphanedPatinfo -- oddb.org -- 05.07.2011 -- mhatakeyama@ywesee.com

$: << File.expand_path("../../src", File.dirname(__FILE__))

require "minitest/autorun"
require "flexmock/minitest"
require "model/orphan"

module ODDB
  class TestOrphanedTextInfo < Minitest::Test
    def setup
      flexmock(ODBA.cache, next_id: 123)
      @model = ODDB::OrphanedTextInfo.new
    end

    def test_name
      description = flexmock("description", name: "name")
      @model.descriptions.update_values({"key" => description})
      assert_equal("name", @model.name)
    end
  end
end
