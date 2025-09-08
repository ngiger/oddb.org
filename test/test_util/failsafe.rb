#!/usr/bin/env ruby

# ODDB::TestFailsafe -- oddb -- 05.07.2011 -- mhatakeyama@ywesee.com

$: << File.expand_path("../../src", File.dirname(__FILE__))

require "minitest/autorun"
require "flexmock/minitest"
require "util/failsafe"

module ODDB
  class StubFailsafe
    include Failsafe
  end

  class TestFailsafe < Minitest::Test
    def setup
      @util = ODDB::StubFailsafe.new
    end

    def stdout_null
      require "tempfile"
      $stdout = Tempfile.open("stdout")
      yield
      $stdout.close
      $stdout = STDOUT
    end

    def test_failsafe
      result = nil
      stdout_null do
        result = @util.failsafe do
          raise
        end
      end
      assert_kind_of(RuntimeError, result)
    end
  end
end
