#!/usr/bin/env ruby

# ODDB::TestNGramSimilarity -- oddb.org -- 01.07.2011 -- mhatakeyama@ywesee.com

$: << File.expand_path("../../src", File.dirname(__FILE__))

module ODDB
  module Util
    module NGramSimilarity
      def self.u(str)
        str
      end
    end
  end
end

require "minitest/autorun"
require "flexmock/minitest"
require "util/ngram_similarity"

module ODDB
  module Util
    class TestNGramSimilarity < Minitest::Test
      def test_compare
        assert_in_delta(0.428, NGramSimilarity.compare("str", "string2", 1), 0.001)
      end
    end
  end # Util
end # ODDB
