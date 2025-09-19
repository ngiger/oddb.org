#!/usr/bin/env ruby
$: << File.expand_path("../src", File.dirname(__FILE__))
$: << File.expand_path("../../../src", File.dirname(__FILE__))
require "minitest/autorun"
require "fiparse"
require "flexmock/minitest"
require "util/workdir"

module ODDB
  class FachinfoDocument
    def odba_id
      1
    end
  end
  module FiParse
    class TestFachinfoNormolytoralDe < Minitest::Test
      def setup
        return if defined?(@@path) && defined?(@@fachinfo) && @@fachinfo
        @@path = File.join(File.dirname(__FILE__), "data", "html", "43916_fi_de_Normolytoral.html")
        @@writer = FachinfoHpricot.new
        File.open(@@path) do |fh|
          @@fachinfo = @@writer.extract(Hpricot(fh), name: "Normolytoral, Pulver zur Herstellung einer Lösung zum Einnehmen im Beutel")
        end
      end
      def test_fachinfo
        assert_equal(ODDB::FachinfoDocument2001, @@fachinfo.class)
      end
      def test_title
        assert_nil(@@writer.title)
      end
      def test_name
        assert_match(/Normolytoral/, @@writer.name.heading)
      end
      def test_chapters
        ODDB::FachinfoDocument2001::CHAPTERS.each do |chapter|
          begin
            res = eval("@@writer.#{chapter}")
          rescue => error
            puts "For 43916_fi_de_Normolytoral.html chapter #{chapter} is not defined"
          end
        end
      end
    end
  end
end
