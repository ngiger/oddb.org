#!/usr/bin/env ruby

# ODDB::View::TestDataFormat -- oddb.org -- 15.04.2011 -- mhatakeyama@ywesee.com

$: << File.expand_path("..", File.dirname(__FILE__))
$: << File.expand_path("../../src", File.dirname(__FILE__))

require "minitest/autorun"
require "flexmock/minitest"
require "view/dataformat"
require "htmlgrid/popuplink"
require "htmlgrid/value"
require "view/pointervalue"
require "util/quanty"
require "htmlgrid/span"

module ODDB
  module View
    class StubDataFormat
      include DataFormat
      def initialize(model, session)
        @model = model
        @session = session
        @lookandfeel = @session.lookandfeel
      end
    end

    module DataFormat
    end
  end
end

module ODDB
  module View
    class TestDataFormat < Minitest::Test
      def setup
        @lnf = flexmock("lookandfeel",
          lookup: "lookup",
          attributes: {},
          disabled?: false,
          _event_url: "_event_url")
        @lnf.should_receive(:enabled?).with(:link_trade_name_to_fachinfo, false).and_return(false)
        @lnf.should_receive(:enabled?).and_return(true)
        @session = flexmock("session", lookandfeel: @lnf)
        @model = flexmock("model")
        @format = ODDB::View::StubDataFormat.new(@model, @session)
      end

      def test_breakline
        assert_equal("111 <br>text <br>text", @format.breakline("111 text text", 0))
      end

      def test_company_name
        company = flexmock("company", name: "name", powerlink: "powerlink", pointer: "pointer")
        flexmock(@model, company: company)
        flexmock(@lnf, enabled?: nil)
        assert_kind_of(HtmlGrid::PopupLink, @format.company_name(@model, @session))
      end

      def test_company_name__powerlink
        company = flexmock("company",
          powerlink: "powerlink",
          pointer: "pointer",
          name: "name")
        flexmock(@model, company: company)
        flexmock(@lnf, enabled?: true)
        assert_kind_of(HtmlGrid::PopupLink, @format.company_name(@model, @session))
      end

      def test_company_name__companylist
        method = flexmock("method", arity: 1)
        company = flexmock("company",
          name: "name",
          powerlink: "powerlink",
          listed?: true,
          method: method,
          pointer: "pointer")
        flexmock(@model, company: company)
        flexmock(@lnf) do |l|
          l.should_receive(:enabled?).with(:powerlink, false).and_return(false)
          l.should_receive(:enabled?).with(:companylist).and_return(true)
          l.should_receive(:language).and_return("language")
        end
        assert_kind_of(HtmlGrid::PopupLink, @format.company_name(@model, @session))
      end

      def test_most_precise_dose
        dose = flexmock("dose",
          is_a?: true,
          qty: 1)
        flexmock(@model, most_precise_dose: dose)
        assert_equal(dose.to_s, @format.most_precise_dose(@model, @session))
      end

      def test_name_base
        flexmock(@session,
          persistent_user_input: "persistent_user_input",
          language: "language")
        indication = flexmock("indication", language: "language")
        registration = flexmock("registration", indication: indication)
        flexmock(@model,
          pointer: "pointer",
          barcode: "barcode",
          name_base: "name_base",
          good_result?: nil,
          registration: registration,
          descr: "descr",
          photo_link: "photo_link",
          has_flickr_photo?: false,
          sequence: nil,
          iksnr: "iksnr")
        flexmock(@format, resolve_suffix: "resolve_suffix")
        result = @format.name_base(@model, @session)
        assert_equal(3, result.length)
        assert_kind_of(HtmlGrid::Link, result[0])
        assert_kind_of(String, result[1])
        assert_kind_of(HtmlGrid::Link, result[2])
      end

      def test_name_link_to_fachinfo
        flexmock(@session,
          persistent_user_input: "persistent_user_input",
          language: "language")
        indication = flexmock("indication", language: "language")
        registration = flexmock("registration", indication: indication)
        flexmock(@model,
          pointer: "pointer",
          barcode: "barcode",
          name_base: "name_base",
          good_result?: nil,
          registration: registration,
          descr: "descr",
          photo_link: "photo_link",
          has_flickr_photo?: false,
          sequence: nil,
          iksnr: "iksnr")
        flexmock(@format, resolve_suffix: "resolve_suffix")
        @lnf.should_receive(:lookup).with(:fachinfo).and_return("fachinfo")

        result = @format.name_base(@model, @session)
        assert_equal(3, result.length)
        assert_kind_of(HtmlGrid::Link, result[0])
        assert_kind_of(String, result[1])
        assert_kind_of(HtmlGrid::Link, result[2])
        skip "Dont't why we cannot set the attributes to fachinfo"
        assert(/fachinfo/i.match(result[2].attributes["title"]), "title should match fachinfo")
      end

      def test_name_base__no_barcode
        flexmock(@session,
          persistent_user_input: "persistent_user_input",
          language: "language")
        indication = flexmock("indication", language: "language")
        registration = flexmock("registration", indication: indication)
        flexmock(@model,
          pointer: "pointer",
          barcode: nil,
          name_base: "name_base",
          good_result?: nil,
          registration: registration,
          descr: "descr",
          photo_link: "photo_link",
          has_flickr_photo?: false,
          sequence: nil,
          iksnr: "iksnr")
        flexmock(@format, resolve_suffix: "resolve_suffix")
        result = @format.name_base(@model, @session)
        assert_equal(3, result.length)
        assert_kind_of(HtmlGrid::Link, result[0])
        assert_kind_of(String, result[1])
        assert_kind_of(HtmlGrid::Link, result[2])
      end

      def test_name_base__good_result
        flexmock(@lnf, disabled?: nil)
        flexmock(@session,
          persistent_user_input: "persistent_user_input",
          language: "language")
        indication = flexmock("indication", language: "language")
        registration = flexmock("registration", indication: indication)
        flexmock(@model,
          pointer: "pointer",
          barcode: "barcode",
          name_base: "name_base",
          good_result?: true,
          registration: registration,
          descr: "descr",
          photo_link: "photo_link",
          has_flickr_photo?: false,
          sequence: nil,
          iksnr: "iksnr")
        flexmock(@format, resolve_suffix: "resolve_suffix")
        result = @format.name_base(@model, @session)
        assert_equal(3, result.length)
        assert_kind_of(HtmlGrid::Link, result[0])
        assert_kind_of(String, result[1])
        assert_kind_of(HtmlGrid::Link, result[2])
      end

      def test_name_base__descr_empty
        flexmock(@session,
          persistent_user_input: "persistent_user_input",
          language: "language")
        indication = flexmock("indication", language: "language")
        registration = flexmock("registration", indication: indication)
        flexmock(@model,
          pointer: "pointer",
          barcode: "barcode",
          name_base: "name_base",
          good_result?: nil,
          registration: registration,
          descr: "",
          photo_link: "photo_link",
          has_flickr_photo?: false,
          sequence: nil,
          iksnr: "iksnr")
        flexmock(@format, resolve_suffix: "resolve_suffix")
        result = @format.name_base(@model, @session)
        assert_equal(3, result.length)
        assert_kind_of(HtmlGrid::Link, result[0])
        assert_kind_of(String, result[1])
        assert_kind_of(HtmlGrid::Link, result[2])
      end

      def test_name_base__photo_link_empty
        flexmock(@session,
          persistent_user_input: "persistent_user_input",
          language: "language")
        indication = flexmock("indication", language: "language")
        registration = flexmock("registration", indication: indication)
        flexmock(@model,
          pointer: "pointer",
          barcode: "barcode",
          name_base: "name_base",
          good_result?: nil,
          registration: registration,
          descr: "descr",
          photo_link: "",
          has_flickr_photo?: false,
          sequence: nil,
          iksnr: "iksnr")
        flexmock(@format, resolve_suffix: "resolve_suffix")
        result = @format.name_base(@model, @session)
        assert_equal(1, result.length)
        assert_kind_of(HtmlGrid::Link, result[0])
      end

      def test_formatted_price
        # This is a testcase for a private method
        flexmock(@model, key: 1.23)
        flexmock(@session)
        flexmock(@lnf,
          format_price: "format_price",
          enabled?: nil)
        assert_kind_of(HtmlGrid::Span, @format.instance_eval('formatted_price("key", @model)', __FILE__, __LINE__))
      end

      def test_formatted_price__price_history
        # This is a testcase for a private method
        flexmock(@model,
          key: 1.23,
          pointer: "pointer",
          has_price_history?: true)
        flexmock(@session,
          persistent_user_input: "persistent_user_input")
        flexmock(@lnf,
          format_price: "format_price",
          enabled?: true)
        res =  @format.instance_eval('formatted_price("key", @model)', __FILE__, __LINE__)
        assert_kind_of(HtmlGrid::Span, @format.instance_eval('formatted_price("key", @model)', __FILE__, __LINE__))
      end

      def test_formatted_price__price_chf_zero
        # This is a testcase for a private method
        flexmock(@model, key: 0)
        flexmock(@lnf,
          disabled?: nil,
          enabled?: nil)
        assert_kind_of(HtmlGrid::Span, @format.instance_eval('formatted_price("key", @model)', __FILE__, __LINE__))
      end

      def test_formatted_price__deductible_unknown
        # This is a testcase for a private method
        flexmock(@model, key: 0)
        flexmock(@lnf, disabled?: true)
        value = @format.instance_eval('formatted_price("key", @model)', __FILE__, __LINE__)
        assert_kind_of(HtmlGrid::Span, value)
        assert_nil(value.attributes["href"])
      end

      def test_price
        flexmock(@model, price: 1.23)
        flexmock(@session)
        flexmock(@lnf,
          format_price: "format_price",
          enabled?: nil)
        assert_kind_of(HtmlGrid::Span, @format.price(@model, @session))
      end

      def test_price_exfactory
        flexmock(@model, price_exfactory: 1.23)
        flexmock(@session)
        flexmock(@lnf,
          format_price: "format_price",
          enabled?: nil)
        assert_kind_of(HtmlGrid::Span, @format.price_exfactory(@model, @session))
      end

      def test_price_public
        flexmock(@model, price_public: 1.23, barcode: nil, pointer: "ptr")
        @lnf = flexmock("lookandfeel",
          lookup: "lookup",
          attributes: {},
          format_price: "format_price",
          enabled?: nil,
          disabled?: false,
          _event_url: "_event_url")
        @session = flexmock("session",
          lookandfeel: @lnf)
        @format = ODDB::View::StubDataFormat.new(@model, @session)
        assert_kind_of(HtmlGrid::Span, @format.price_public(@model, @session))
      end

      def test_price_public_link_to_comparision
        flexmock(@model, price_public: 1.23, barcode: nil, pointer: "ptr")
        @lnf.should_receive(:format_price).and_return("format_price")
        @lnf.should_receive(:enabled?).with(:price_history).and_return(false)
        @lnf.should_receive(:enabled?).with(:link_pubprice_to_price_comparison, false).and_return(true)
        @session = flexmock("session",
          lookandfeel: @lnf)
        @format = ODDB::View::StubDataFormat.new(@model, @session)
        assert_kind_of(HtmlGrid::Link, @format.price_public(@model, @session))
      end
    end
  end # View
end # ODDB
