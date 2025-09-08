#!/usr/bin/env ruby

# ODDB::View::TestCenteredSearchForm -- oddb.org -- 24.03.2011 -- mhatakeyama@ywesee.com

$: << File.expand_path("..", File.dirname(__FILE__))
$: << File.expand_path("../../src", File.dirname(__FILE__))

require "minitest/autorun"
require "flexmock/minitest"
require "view/centeredsearchform"

module ODDB
  module View
    class TestPayPalForm < Minitest::Test
      def setup
        @lnf = flexmock("lookandfeel",
          attributes: {},
          resource_global: "resource_global")
        @session = flexmock("session", lookandfeel: @lnf)
        @model = flexmock("model")
        @navi = PayPalForm.new(@model, @session)
      end

      def test_donation_logo
        assert_kind_of(HtmlGrid::Input, @navi.donation_logo(@model, @session))
      end

      def test_hidden_fields
        flexmock(@lnf,
          _event_url: "_event_url",
          base_url: "base_url")
        context = flexmock("context", hidden: "h")
        assert_equal("hhhhhhhhh", @navi.hidden_fields(context))
      end
    end # TestCenteredNavigation

    class TestCenteredSearchForm < Minitest::Test
      def setup
        @zones = flexmock("zones", sort_by: [], each_with_index: nil)
        @lnf = flexmock("lookandfeel",
          lookup: "lookup",
          attributes: {},
          _event_url: "_event_url",
          disabled?: nil,
          enabled?: nil,
          zones: @zones,
          base_url: "base_url")
        @session = flexmock("session",
          lookandfeel: @lnf,
          zone: "zone",
          event: "event")
        @model = flexmock("model")
        @form = CenteredSearchForm.new(@model, @session)
      end

      def test_init
        expected = "
function get_to(url) {
  var url2 = url.replace('/,','/').replace(/\\?$/,'').replace('\\?,', ',').replace('ean,', 'ean/').replace(/\\?$/, '');
  console.log('get_to window.top.location.replace url '+ url + ' url2 ' + url2);
  if (window.location.href == url2 || window.top.location.href == url2) { return; }
  var form = document.createElement(\"form\");
  form.setAttribute(\"method\", \"GET\");
  form.setAttribute(\"action\", url2);
  document.body.appendChild(form);
  form.submit();
}


if (search_query.value!='lookup') {

  var href = '_event_url' + encodeURIComponent(search_query.value.replace(/\\//, '%2F'));
  if (this.search_type) {
    href += '/search_type/' + this.search_type.value + '#best_result';
  }
  get_to(href);
};
return false;
"
        assert_equal(expected, @form.init["onSubmit"])
      end

      def test_search_help
        assert_kind_of(HtmlGrid::Button, @form.search_help(@model, @session))
      end

      def test_search_reset
        @lnf = flexmock("lookandfeel",
          lookup: "lookup",
          attributes: {},
          _event_url: "_event_url",
          disabled?: nil,
          enabled?: true,
          zones: @zones,
          base_url: "base_url")
        @session = flexmock("session",
          lookandfeel: @lnf,
          zone: "zone",
          event: "event")
        @form = CenteredSearchForm.new(@model, @session)
        assert_kind_of(HtmlGrid::Button, @form.search_reset(@model, @session))
      end
    end # TestCenteredSearchForm

    class TestCenteredSearchComposite < Minitest::Test
      def setup
        @lnf = flexmock("lookandfeel",
          enabled?: nil,
          attributes: {},
          lookup: "lookup",
          _event_url: "_event_url",
          event_url: "event_url")
        @app = flexmock("app")
        @session = flexmock("session",
          lookandfeel: @lnf,
          app: @app)
        @model = flexmock("model")
        @composite = CenteredSearchComposite.new(@model, @session)
      end

      def test_atc_chooser
        @lnf = flexmock("lookandfeel",
          enabled?: true,
          attributes: {},
          direct_event: "direct_event",
          lookup: "lookup",
          _event_url: "_event_url",
          event_url: "event_url")
        @session = flexmock("session",
          lookandfeel: @lnf,
          app: @app)
        @composite = CenteredSearchComposite.new(@model, @session)
        assert_kind_of(ODDB::View::CenteredNavigationLink, @composite.atc_chooser(@model, @session))
      end

      def test_atc_ddd_size
        flexmock(@app, atc_ddd_count: "atc_ddd_count")
        assert_equal("atc_ddd_count&nbsp;", @composite.atc_ddd_size(@model, @session))
      end

      def test_beta
        assert_kind_of(HtmlGrid::Link, @composite.beta(@model, @session))
      end

      def test_database_size
        flexmock(@app, package_count: "package_count")
        assert_equal("package_count&nbsp;", @composite.database_size(@model, @session))
      end

      def test_database_last_updated
        assert_kind_of(HtmlGrid::DateValue, @composite.database_last_updated(@model, @session))
      end

      def test_ddd_count_text
        assert_kind_of(HtmlGrid::Link, @composite.ddd_count_text(@model, @session))
      end

      def test_divider
        assert_kind_of(HtmlGrid::Span, @composite.divider(@model, @session))
      end

      def test_download_export
        assert_kind_of(HtmlGrid::Link, @composite.download_export(@model, @session))
      end

      def test_download_generics
        assert_kind_of(HtmlGrid::Link, @composite.download_generics(@model, @session))
      end

      def test_export_divider
        assert_kind_of(HtmlGrid::Span, @composite.export_divider(@model, @session))
      end

      def test_fachinfo_size
        flexmock(@app, fachinfo_count: "fachinfo_count")
        assert_equal("fachinfo_count&nbsp;", @composite.fachinfo_size(@model, @session))
      end

      def test_interactions
        assert_kind_of(HtmlGrid::Link, @composite.interactions(@model, @session))
      end

      def test_limitation_size
        flexmock(@app, limitation_text_count: "limitation_text_count")
        assert_equal("limitation_text_count&nbsp;", @composite.limitation_size(@model, @session))
      end

      def test_narcotics_size
        flexmock(@app, narcotics: "narcotics")
        # 9 is the length of the string narcotics
        assert_equal("9&nbsp;", @composite.narcotics_size(@model, @session))
      end

      def test_recent_registrations
        flexmock(@app, recent_registration_count: "recent_registration_count")
        result = @composite.recent_registrations(@model, @session)
        assert_equal(5, result.length)
        assert_kind_of(HtmlGrid::DateValue, result[0])
        assert_equal("<br>", result[1])
        assert_equal("recent_registration_count", result[2])
        assert_equal("&nbsp;", result[3])
        assert_kind_of(HtmlGrid::Link, result[4])
      end

      def test_paypal
        @lnf = flexmock("lookandfeel",
          enabled?: true,
          attributes: {},
          lookup: "lookup",
          resource_global: "resource_global",
          _event_url: "_event_url",
          event_url: "event_url")
        @session = flexmock("session",
          lookandfeel: @lnf,
          app: @app)
        @composite = CenteredSearchComposite.new(@model, @session)
        assert_kind_of(ODDB::View::PayPalForm, @composite.paypal(@model, @session))
      end

      def test_patinfo_size
        flexmock(@app, patinfo_count: "patinfo_count")
        assert_equal("patinfo_count&nbsp;", @composite.patinfo_size(@model, @session))
      end

      def test_vaccines_size
        flexmock(@app, vaccine_count: "vaccine_count")
        assert_equal("vaccine_count&nbsp;", @composite.vaccines_size(@model, @session))
      end
    end # TestCenteredSearchComposite
  end # View
end # ODDB
