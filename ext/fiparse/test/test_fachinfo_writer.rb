#!/usr/bin/env ruby
# ODDB::FiParse::TestFachinfoWriter -- oddb.org -- 11.04.2011 -- mhatakeyama@ywesee.com

require "hpricot"

$: << File.expand_path("../src", File.dirname(__FILE__))
$: << File.expand_path("../../../src", File.dirname(__FILE__))

require "minitest/autorun"
require "flexmock/minitest"
require "fachinfo_writer"

module ODDB
  module FiParse
    class TestFachinfoWriter < Minitest::Test
      def setup
        @writer = ODDB::FiParse::FachinfoWriter.new
      end

      def test_to_fachinfo
        flexmock(ODBA.cache, next_id: 123)
        assert_kind_of(ODDB::FachinfoDocument, @writer.to_fachinfo)
      end

      def test_to_fachinfo__amzv
        @writer.instance_eval('@amzv = "amzv"', __FILE__, __LINE__)
        flexmock(ODBA.cache, next_id: 123)
        assert_kind_of(ODDB::FachinfoDocument, @writer.to_fachinfo)
      end

      # The followings are testcases for private methods
      def test_set_templates
        flexmock("chapter", heading: nil)
        assert_nil(@writer.instance_eval("set_templates(chapter)", __FILE__, __LINE__))
      end

      def test_set_templates__amzv
        flexmock("chapter", heading: "AMZV")
        result = @writer.instance_eval("set_templates(chapter)", __FILE__, __LINE__)
        assert_equal(13, result.length)
        assert_kind_of(ODDB::Text::Chapter, result[0])
      end

      def test_set_templates__galenische
        flexmock("chapter", heading: "Galenische Form")
        result = @writer.instance_eval("set_templates(chapter)", __FILE__, __LINE__)
        assert_equal(11, result.length)
        assert_kind_of(ODDB::Text::Chapter, result[0])
      end

      def test_set_templates__zusammensetzung
        flexmock("chapter", heading: "Zusammensetzung")
        result = @writer.instance_eval("set_templates(chapter)", __FILE__, __LINE__)
        assert_equal(1, result.length)
        assert_kind_of(ODDB::Text::Chapter, result[0])
      end

      def test_set_templates__eigenschaften
        flexmock("chapter", heading: "Eigenschaften")
        result = @writer.instance_eval("set_templates(chapter)", __FILE__, __LINE__)
        assert_equal(1, result.length)
        assert_kind_of(ODDB::Text::Chapter, result[0])
      end

      def test_set_templates__angaben
        flexmock("chapter", heading: "Weitere Angaben")
        result = @writer.instance_eval("set_templates(chapter)", __FILE__, __LINE__)
        assert_equal(1, result.length)
        assert_kind_of(ODDB::Text::Chapter, result[0])
      end

      def test_set_templates__pharmakokinetik
        flexmock("chapter", heading: "Pharmakokinetik")
        result = @writer.instance_eval("set_templates(chapter)", __FILE__, __LINE__)
        assert_equal(1, result.length)
        assert_kind_of(ODDB::Text::Chapter, result[0])
      end

      def test_set_templates__indikationen
        flexmock("chapter", heading: "Indikationen")
        result = @writer.instance_eval("set_templates(chapter)", __FILE__, __LINE__)
        assert_equal(4, result.length)
        assert_kind_of(ODDB::Text::Chapter, result[0])
      end

      def test_set_templates__interaktionen
        flexmock("chapter", heading: "Interaktionen")
        result = @writer.instance_eval("set_templates(chapter)", __FILE__, __LINE__)
        assert_equal(1, result.length)
        assert_kind_of(ODDB::Text::Chapter, result[0])
      end

      def test_set_templates__berdosierung
        flexmock("chapter", heading: "berdosierung")
        result = @writer.instance_eval("set_templates(chapter)", __FILE__, __LINE__)
        assert_equal(1, result.length)
        assert_kind_of(ODDB::Text::Chapter, result[0])
      end

      def test_set_templates__sonstige
        flexmock("chapter", heading: "Sonstige")
        result = @writer.instance_eval("set_templates(chapter)", __FILE__, __LINE__)
        assert_equal(1, result.length)
        assert_kind_of(ODDB::Text::Chapter, result[0])
      end

      def test_set_templates__auslieferung
        flexmock("chapter", heading: "Auslieferung")
        result = @writer.instance_eval("set_templates(chapter)", __FILE__, __LINE__)
        assert_equal(1, result.length)
        assert_kind_of(ODDB::Text::Chapter, result[0])
      end

      def test_set_templates__vertrieb
        flexmock("chapter", heading: "Vertrieb")
        result = @writer.instance_eval("set_templates(chapter)", __FILE__, __LINE__)
        assert_equal(1, result.length)
        assert_kind_of(ODDB::Text::Chapter, result[0])
      end

      def test_set_templates__hersteller
        flexmock("chapter", heading: "Hersteller")
        result = @writer.instance_eval("set_templates(chapter)", __FILE__, __LINE__)
        assert_equal(1, result.length)
        assert_kind_of(ODDB::Text::Chapter, result[0])
      end

      def test_set_templates__iks_nummern
        flexmock("chapter", heading: "IKS-Nummern?")
        result = @writer.instance_eval("set_templates(chapter)", __FILE__, __LINE__)
        assert_equal(2, result.length)
        assert_kind_of(ODDB::Text::Chapter, result[0])
      end

      def test_set_templates__stand_der_information
        flexmock("chapter", heading: "Stand der Information")
        result = @writer.instance_eval("set_templates(chapter)", __FILE__, __LINE__)
        assert_equal(1, result.length)
        assert_kind_of(ODDB::Text::Chapter, result[0])
      end

      def test_set_templates__pharmakokinetik2
        @writer.instance_eval('@amzv = "amzv"', __FILE__, __LINE__)
        flexmock("chapter", heading: "Pharmakokinetik")
        result = @writer.instance_eval("set_templates(chapter)", __FILE__, __LINE__)
        assert_equal(1, result.length)
        assert_kind_of(ODDB::Text::Chapter, result[0])
      end

      def test_set_templates__pr_klinische_daten
        @writer.instance_eval('@amzv = "amzv"', __FILE__, __LINE__)
        flexmock("chapter", heading: "Pr klinische Daten")
        result = @writer.instance_eval("set_templates(chapter)", __FILE__, __LINE__)
        assert_equal(1, result.length)
        assert_kind_of(ODDB::Text::Chapter, result[0])
      end

      def test_set_templates__sonstige2
        @writer.instance_eval('@amzv = "amzv"', __FILE__, __LINE__)
        flexmock("chapter", heading: "Sonstige")
        result = @writer.instance_eval("set_templates(chapter)", __FILE__, __LINE__)
        assert_equal(1, result.length)
        assert_kind_of(ODDB::Text::Chapter, result[0])
      end

      def test_set_templates__weitere_angaben
        @writer.instance_eval('@amzv = "amzv"', __FILE__, __LINE__)
        flexmock("chapter", heading: "Weitere Angaben")
        result = @writer.instance_eval("set_templates(chapter)", __FILE__, __LINE__)
        assert_equal(1, result.length)
        assert_kind_of(ODDB::Text::Chapter, result[0])
      end

      def test_set_templates__zulassungsvermerk
        @writer.instance_eval('@amzv = "amzv"', __FILE__, __LINE__)
        flexmock("chapter", heading: "Zulassungsvermerk")
        result = @writer.instance_eval("set_templates(chapter)", __FILE__, __LINE__)
        assert_equal(1, result.length)
        assert_kind_of(ODDB::Text::Chapter, result[0])
      end

      def test_set_templates__packungen
        @writer.instance_eval('@amzv = "amzv"', __FILE__, __LINE__)
        flexmock("chapter", heading: "Packungen")
        result = @writer.instance_eval("set_templates(chapter)", __FILE__, __LINE__)
        assert_equal(2, result.length)
        assert_kind_of(ODDB::Text::Chapter, result[0])
      end

      def test_set_templates__registrationsinhaber
        @writer.instance_eval('@amzv = "amzv"', __FILE__, __LINE__)
        flexmock("chapter", heading: "Registrationsinhaber")
        result = @writer.instance_eval("set_templates(chapter)", __FILE__, __LINE__)
        assert_equal(1, result.length)
        assert_kind_of(ODDB::Text::Chapter, result[0])
      end

      def test_set_templates__hersteller2
        @writer.instance_eval('@amzv = "amzv"', __FILE__, __LINE__)
        flexmock("chapter", heading: "Hersteller")
        result = @writer.instance_eval("set_templates(chapter)", __FILE__, __LINE__)
        assert_equal(1, result.length)
        assert_kind_of(ODDB::Text::Chapter, result[0])
      end

      def test_set_templates__stand_der_information2
        @writer.instance_eval('@amzv = "amzv"', __FILE__, __LINE__)
        flexmock("chapter", heading: "Stand der Information")
        result = @writer.instance_eval("set_templates(chapter)", __FILE__, __LINE__)
        assert_equal(1, result.length)
        assert_kind_of(ODDB::Text::Chapter, result[0])
      end
    end
  end # FiParse
end # ODDB
