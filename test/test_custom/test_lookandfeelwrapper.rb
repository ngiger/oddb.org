#!/usr/bin/env ruby

# SBSM::LookandfeelWrapper -- oddb.org -- 11.04.2012 -- yasaka@ywesee.com
# SBSM::LookandfeelWrapper -- oddb.org -- 03.03.2011 -- mhatakeyama@ywesee.com

$: << File.expand_path("../../src", File.dirname(__FILE__))

require "minitest/autorun"
require "flexmock/minitest"
require "custom/lookandfeelwrapper"

module ODDB
  module State
    module Drugs
      class AtcChooser < State::Drugs::Global; end
    end

    module Migel
      class Alphabetical < Global; end
    end
  end
end

module SBSM
  class StubLookandfeelWrapper < LookandfeelWrapper
    def self.filter(sequence)
      "self.class::SEQUENCE_FILTER"
    end
    SEQUENCE_FILTER = method(:filter)
  end

  class TestLookandfeelWrapper < Minitest::Test
    def setup
      session = flexmock("session") do |s|
        s.should_receive(:flavor)
        s.should_receive(:language)
      end
      @component = flexmock("component") do |c|
        c.should_receive(:session).and_return(session)
        c.should_receive(:sequence_filter).and_return("sequence_filter")
      end
      @look = LookandfeelWrapper.new(@component)
    end

    def test_format_price
      assert_equal("1.23", @look.format_price(123.4))
    end

    def test_has_sequence_filter?
      assert_equal(false, @look.has_sequence_filter?)
    end

    def test_sequence_filter
      wrapper = StubLookandfeelWrapper.new(@component)
      assert_equal("self.class::SEQUENCE_FILTER", wrapper.sequence_filter(1))
    end
  end
end

module ODDB
  class TestLookandfeelStandardResult < Minitest::Test
    def setup
      session = flexmock("session") do |s|
        s.should_receive(:flavor)
        s.should_receive(:language)
      end
      component = flexmock("component") do |c|
        c.should_receive(:session).and_return(session)
      end
      @look = LookandfeelStandardResult.new(component)
    end

    def test_compare_list_components
      expected = {
        [1, 0] => :fachinfo,
        [2, 0] => :patinfo,
        [3, 0] => :name_base,
        [4, 0] => :company_name,
        [5, 0] => :comparable_size,
        [6, 0] => :compositions,
        [7, 0] => :price_public,
        [8, 0] => :price_difference,
        [9, 0] => :deductible,
        [10, 0] => :ikscat
      }
      assert_equal(expected, @look.compare_list_components)
    end

    def test_explain_result_components
      expected = {[0, 0] => :explain_original,
                  [0, 1] => :explain_generic,
                  [0, 2] => "explain_unknown",
                  [0, 3] => "explain_expired",
                  [0, 4] => :explain_homeopathy,
                  [0, 5] => :explain_anthroposophy,
                  [0, 6] => :explain_phytotherapy,
                  [0, 7] => :explain_cas,
                  [1, 0] => :explain_parallel_import,
                  [1, 1] => :explain_comarketing,
                  [1, 2] => :explain_vaccine,
                  [1, 3] => :explain_narc,
                  [1, 4] => :explain_fachinfo,
                  [1, 5] => :explain_patinfo,
                  [1, 6] => :explain_limitation,
                  [1, 7] => :explain_google_search,
                  [1, 8] => :explain_feedback,
                  [2, 0] => "explain_efp",
                  [2, 1] => "explain_pbp",
                  [2, 2] => "explain_pr",
                  [2, 3] => :explain_deductible,
                  [2, 4] => "explain_sl",
                  [2, 5] => "explain_slo",
                  [2, 6] => "explain_slg",
                  [2, 7] => :explain_lppv}
      assert_equal(expected, @look.explain_result_components)
    end

    def test_result_list_components
      expected = {[0, 0] => :limitation_text,
                  [1, 0] => :fachinfo,
                  [2, 0] => :patinfo,
                  [3, 0] => :narcotic,
                  [4, 0] => :complementary_type,
                  [5, 0, 0] => "result_item_start",
                  [5, 0, 1] => :name_base,
                  [5, 0, 2] => "result_item_end",
                  [6, 0] => :galenic_form,
                  [7, 0] => :comparable_size,
                  [8, 0] => :price_exfactory,
                  [9, 0] => :price_public,
                  [10, 0] => :deductible,
                  [11, 0] => :substances,
                  [12, 0] => :company_name,
                  [13, 0] => :ikscat,
                  [14, 0] => :registration_date,
                  [15, 0] => :feedback,
                  [16, 0] => :google_search,
                  [17, 0] => :notify}
      assert_equal(expected, @look.result_list_components)
    end
  end

  class TestLookandfeelGenerika < Minitest::Test
    def setup
      session = flexmock("session") do |s|
        s.should_receive(:flavor)
        s.should_receive(:language)
      end
      component = flexmock("component") do |c|
        c.should_receive(:session).and_return(session)
        c.should_receive(:navigation).and_return("navigation")
        c.should_receive(:zones).and_return(["zones"])
      end
      @look = LookandfeelGenerika.new(component)
    end

    def test_navigation
      assert_equal("navigation", @look.navigation)
    end

    def test_zones
      assert_equal([:drugs, :user, :companies], @look.zones)
    end
  end

  class TestLookandfeelJustMedical < Minitest::Test
    def setup
      @session = flexmock("session") do |s|
        s.should_receive(:flavor)
        s.should_receive(:language)
      end
      component = flexmock("component") do |c|
        c.should_receive(:session).and_return(@session)
      end
      @look = LookandfeelJustMedical.new(component)
    end

    def test_compare_list_components
      expected = {
        [2, 0] => :fachinfo,
        [3, 0] => :patinfo,
        [4, 0] => :company_name,
        [5, 0] => :comparable_size,
        [6, 0] => :compositions,
        [7, 0] => :price_public,
        [8, 0] => :price_difference,
        [9, 0] => :deductible,
        [10, 0] => :ikscat
      }
      assert_equal(expected, @look.compare_list_components)
    end

    def test_explain_result_components
      expected = {[0, 0] => :explain_original,
                  [0, 1] => :explain_generic,
                  [0, 2] => :explain_comarketing,
                  [0, 3] => :explain_vaccine,
                  [0, 4] => "explain_unknown",
                  [0, 5] => "explain_expired",
                  [0, 6] => :explain_cas,
                  [1, 0] => :explain_limitation,
                  [1, 1] => :explain_fachinfo,
                  [1, 2] => :explain_patinfo,
                  [1, 3] => :explain_narc,
                  [1, 4] => :explain_anthroposophy,
                  [1, 5] => :explain_homeopathy,
                  [1, 6] => :explain_phytotherapy,
                  [1, 7] => :explain_parallel_import,
                  [2, 0] => "explain_pbp",
                  [2, 1] => :explain_deductible,
                  [2, 2] => "explain_sl",
                  [2, 3] => "explain_slo",
                  [2, 4] => "explain_slg",
                  [2, 5] => :explain_feedback,
                  [2, 6] => :explain_lppv,
                  [2, 7] => :explain_google_search}
      assert_equal(expected, @look.explain_result_components)
    end

    def test_zones
      expected = [:interactions, State::Drugs::Init, State::Drugs::AtcChooser, State::Drugs::Sequences]
      assert_equal(expected, @look.zones)
    end

    def test_zone_navigation__else
      flexstub(@session) do |s|
        s.should_receive(:zone).and_return(:else)
      end
      assert_equal([], @look.zone_navigation)
    end

    def test_navigation
      flexstub(@session) do |s|
        s.should_receive(:zone)
      end
      expected = [:meddrugs_update, :legal_note, :data_declaration, :home]
      assert_equal(expected, @look.navigation)
    end

    def test_result_list_components
      expected = {
        [0, 0] => :limitation_text,
        [1, 0] => :fachinfo,
        [2, 0] => :patinfo,
        [3, 0] => :narcotic,
        [4, 0] => :complementary_type,
        [5, 0, 0] => "result_item_start",
        [5, 0, 1] => :name_base,
        [5, 0, 2] => "result_item_end",
        [6, 0] => :comparable_size,
        [7, 0] => :price_public,
        [8, 0] => :deductible,
        [9, 0] => :compositions,
        [10, 0] => :company_name,
        [11, 0] => :ikscat,
        [12, 0] => :registration_date,
        [13, 0] => :google_search
      }
      assert_equal(expected, @look.result_list_components)
    end
  end

  class TestLookandfeelSwissmedic < Minitest::Test
    def setup
      @session = flexmock("session") do |s|
        s.should_receive(:flavor)
        s.should_receive(:language)
      end
      @component = flexmock("component") do |c|
        c.should_receive(:session).and_return(@session)
      end
      @look = LookandfeelSwissmedic.new(@component)
    end

    def test_enabled
      flexstub(@component) do |c|
        c.should_receive(:enabled?).and_return("enabled?")
      end
      assert_equal("enabled?", @look.enabled?("event"))
    end

    def test_enabled__false
      assert_equal(false, @look.enabled?(:query_limit))
    end
  end

  class TestLookandfeelOekk < Minitest::Test
    def setup
      @session = flexmock("session") do |s|
        s.should_receive(:flavor)
        s.should_receive(:language)
      end
      @component = flexmock("component") do |c|
        c.should_receive(:session).and_return(@session)
      end
      @look = LookandfeelOekk.new(@component)
    end

    def test_compare_list_components
      expected = {
        [1, 0] => :name_base,
        [2, 0] => :company_name,
        [3, 0] => :most_precise_dose,
        [4, 0] => :comparable_size,
        [5, 0] => :compositions,
        [6, 0] => :price_public,
        [7, 0] => :price_difference,
        [8, 0] => :deductible,
        [9, 0] => :ikscat,
        [10, 0] => :fachinfo,
        [11, 0] => :patinfo
      }

      assert_equal(expected, @look.compare_list_components)
    end

    def test_explain_result_components
      expected = {[0, 0] => "explain_expired",
                  [0, 1] => :explain_homeopathy,
                  [0, 2] => :explain_anthroposophy,
                  [0, 3] => :explain_phytotherapy,
                  [0, 4] => :explain_parallel_import,
                  [0, 5] => :explain_vaccine,
                  [1, 0] => :explain_fachinfo,
                  [1, 1] => :explain_patinfo,
                  [1, 2] => :explain_limitation,
                  [1, 3] => :explain_narc,
                  [1, 4] => "explain_pbp",
                  [1, 5] => "explain_pr",
                  [1, 6] => :explain_deductible}

      assert_equal(expected, @look.explain_result_components)
    end

    def test_languages
      assert_equal([:de, :fr, :en], @look.languages)
    end

    def test_result_list_components
      expected = {
        [0, 0, 0] => "result_item_start",
        [0, 0, 1] => :name_base,
        [0, 0, 2] => "result_item_end",
        [1, 0] => :galenic_form,
        [2, 0] => :most_precise_dose,
        [3, 0] => :comparable_size,
        [4, 0] => :price_public,
        [5, 0] => :deductible,
        [6, 0] => :company_name,
        [7, 0] => :limitation_text,
        [8, 0] => :narcotic,
        [9, 0] => :complementary_type,
        [10, 0] => :fachinfo,
        [11, 0] => :patinfo
      }
      assert_equal(expected, @look.result_list_components)
    end
  end

  class TestLookandfeelMobile < Minitest::Test
    def setup
      @session = flexmock("session") do |s|
        s.should_receive(:flavor)
        s.should_receive(:language)
      end
      @component = flexmock("component") do |c|
        c.should_receive(:session).and_return(@session)
      end
      @look = LookandfeelMobile.new(@component)
    end

    def test_result_list_components
      expected = {
        [0, 0]	=>	:limitation_text,
        [1, 0]	=> :minifi,
        [2, 0]	=> :fachinfo,
        [3, 0]	=>	:patinfo,
        [4, 0, 0]	=>	:narcotic,
        [4, 0, 1]	=>	:complementary_type,
        [4, 0, 2]	=>	:comarketing,
        [5, 0, 0]	=>	"result_item_start",
        [5, 0, 1]	=>	:name_base,
        [5, 0, 2]	=>	"result_item_end",
        [6, 0]	=>	:comparable_size,
        [7, 0]	=>	:price_exfactory,
        [8, 0]	=>	:price_public,
        [9, 0]	=>	:ddd_price,
        [10, 0]	=>	:compositions,
        [11, 0]	=>	:ikscat,
        [12, 0]	=>	:feedback,
        [13, 0]	=> :google_search,
        [14, 0]	=>	:notify
      }
      assert_equal(expected, @look.result_list_components)
    end

    def test_explain_result_components
      expected = {[0, 0] => :explain_original,
                  [0, 1] => :explain_generic,
                  [0, 2] => "explain_unknown",
                  [0, 3] => "explain_expired",
                  [0, 4] => :explain_homeopathy,
                  [0, 5] => :explain_anthroposophy,
                  [0, 6] => :explain_phytotherapy,
                  [0, 7] => :explain_cas,
                  [0, 8] => :explain_parallel_import,
                  [0, 9] => :explain_comarketing,
                  [0, 10] => :explain_narc,
                  [0, 11] => :explain_google_search,
                  [0, 12] => :explain_feedback,
                  [1, 0] => :explain_vaccine,
                  [1, 1] => :explain_minifi,
                  [1, 2] => :explain_fachinfo,
                  [1, 3] => :explain_patinfo,
                  [1, 4] => :explain_limitation,
                  [1, 5] => :explain_ddd_price,
                  [1, 6] => "explain_efp",
                  [1, 7] => "explain_pbp",
                  [1, 8] => "explain_pr",
                  [1, 9] => "explain_sl",
                  [1, 10] => "explain_slo",
                  [1, 11] => "explain_slg",
                  [1, 12] => :explain_lppv}
      assert_equal(expected, @look.explain_result_components)
    end
  end

  class TestLookandfeelSwissMedInfo < Minitest::Test
    def setup
      @session = flexmock("session") do |s|
        s.should_receive(:flavor)
        s.should_receive(:language)
      end
      @component = flexmock("component") do |c|
        c.should_receive(:session).and_return(@session)
      end
      @look = LookandfeelSwissMedInfo.new(@component)
    end

    def test_compare_list_components
      expected = {
        [0, 0] => :fachinfo,
        [1, 0] => :patinfo,
        [2, 0] => :name_base,
        [3, 0] => :company_name,
        [4, 0] => :most_precise_dose,
        [5, 0] => :comparable_size,
        [6, 0] => :compositions,
        [7, 0] => :price_public,
        [8, 0] => :price_difference,
        [9, 0] => :ddd_price,
        [10, 0] => :ikscat
      }
      assert_equal(expected, @look.compare_list_components)
    end

    def test_explain_result_components
      expected = {[0, 0] => :explain_original,
                  [0, 1] => :explain_generic,
                  [0, 2] => "explain_expired",
                  [0, 3] => "explain_pbp",
                  [0, 4] => :explain_deductible,
                  [0, 5] => :explain_ddd_price,
                  [0, 6] => :explain_fachinfo,
                  [1, 0] => :explain_patinfo,
                  [1, 1] => :explain_feedback,
                  [1, 2] => :explain_google_search,
                  [1, 3] => "explain_sl",
                  [1, 4] => "explain_slo",
                  [1, 5] => "explain_slg",
                  [1, 6] => :explain_lppv}
      assert_equal(expected, @look.explain_result_components)
    end

    def test_result_list_components
      expected = {
        [0, 0] => :fachinfo,
        [1, 0] => :patinfo,
        [2, 0] => :comarketing,
        [3, 0, 0] => "result_item_start",
        [2, 0, 1] => :name_base,
        [3, 0, 2] => "result_item_end",
        [4, 0] => :galenic_form,
        [5, 0] => :most_precise_dose,
        [6, 0] => :comparable_size,
        [7, 0] => :price_public,
        [8, 0] => :deductible,
        [9, 0] => :company_name,
        [10, 0] => :ddd_price,
        [11, 0] => "nbsp",
        [12, 0] => :ikscat,
        [13, 0] => :feedback,
        [14, 0] => :google_search
      }
      assert_equal(expected, @look.result_list_components)
    end

    def test_section_style
      expected = "font-size: 18px; margin-top: 8px; line-height: 1.4em; max-width: 600px"
      assert_equal(expected, @look.section_style)
    end
  end

  class TestLookandfeelComplementaryType < Minitest::Test
    def setup
      @session = flexmock("session") do |s|
        s.should_receive(:flavor)
        s.should_receive(:language)
      end
      @component = flexmock("component") do |c|
        c.should_receive(:session).and_return(@session)
      end
      @look = LookandfeelComplementaryType.new(@component)
    end

    def test_explain_result_components
      expected = {
        [0, 0]	=>	:explain_minifi,
        [0, 1]	=>	:explain_fachinfo,
        [0, 2]	=>	:explain_patinfo,
        [0, 3]	=>	:explain_limitation,
        [0, 4]	=>	:explain_parallel_import,
        [0, 5]	=>	:explain_comarketing,
        [0, 6]	=>	:explain_google_search,
        [0, 7]	=>	:explain_feedback,
        [1, 0]	=>	"explain_expired",
        [1, 1]	=>	"explain_efp",
        [1, 2]	=>	"explain_pbp",
        [1, 3]	=>	"explain_pr",
        [1, 4]	=>	:explain_deductible,
        [1, 5]	=>	:explain_ddd_price,
        [1, 6]	=>	"explain_sl",
        [1, 7]	=>	:explain_lppv
      }
      assert_equal(expected, @look.explain_result_components)
    end

    def test_result_list_components
      expected = {
        [0, 0]	=>	:limitation_text,
        [1, 0]	=> :minifi,
        [2, 0]	=> :fachinfo,
        [3, 0]	=>	:patinfo,
        [4, 0, 0]	=>	:narcotic,
        [4, 0, 1]	=>	:comarketing,
        [5, 0, 0]	=>	"result_item_start",
        [5, 0, 1]	=>	:name_base,
        [5, 0, 2]	=>	"result_item_end",
        [6, 0]	=>	:comparable_size,
        [7, 0]	=>	:price_exfactory,
        [8, 0]	=>	:price_public,
        [9, 0]	=>	:deductible,
        [10, 0]	=>	:ddd_price,
        [11, 0]	=>	:compositions,
        [12, 0]	=>	:company_name,
        [13, 0]	=>	:ikscat,
        [14, 0]	=>	:feedback,
        [15, 0]	=> :google_search,
        [16, 0]	=>	:notify
      }
      assert_equal(expected, @look.result_list_components)
    end
  end
end
