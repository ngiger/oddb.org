#!/usr/bin/env ruby

# ODDB::View::Rss::TestPackage -- oddb.org -- 24.06.2011 -- mhatakeyama@ywesee.com

$: << File.expand_path("../..", File.dirname(__FILE__))
$: << File.expand_path("../../../src", File.dirname(__FILE__))

require "minitest/autorun"
require "flexmock/minitest"
require "view/htmlgrid/composite"
require "view/rss/package"
require "htmlgrid/span"
require "model/index_therapeuticus"
require "model/package"
require "sbsm/validator"
require "state/drugs/compare"
require "stub/cgi"

module ODDB
  module View
    module Rss
      class TestPackage < Minitest::Test
        def setup
          @app = flexmock("app")
          @result_list_components = flexmock("result_list_components",
            has_value?: false)
          @lnf = flexmock("lookandfeel",
            format_date: true,
            result_list_components: @result_list_components,
            lookup: "lookup",
            _event_url: "_event_url",
            resource: "resource",
            enabled?: nil,
            language: "language",
            disabled?: nil,
            attributes: {},
            format_price: "format_price")
          @session = flexmock("session",
            cgi: CGI.new,
            app: @app,
            lookandfeel: @lnf,
            language: "language",
            error: "error",
            persistent_user_input: "persistent_user_input")
          price_public = flexmock("price_public",
            valid_from: Time.utc(2011, 2, 3),
            to_f: 1.0,
            to_i: 1,
            to_s: "price_public")
          flexmock(price_public,
            :- => price_public,
            :/ => price_public,
            :* => price_public)
          atc_class = flexmock("atc_class",
            code: "code",
            has_ddd?: true,
            description: "description",
            parent_code: "parent_code",
            pointer: "pointer")
          flexmock(@app, atc_class: atc_class)
          limitation_text = flexmock("limitation_text", language: "language")
          @model = flexmock("model",
            ikscat: "ikscat",
            lppv: "lppv",
            registration_date: Date.new(2000, 1, 1),
            sequence_date: Date.new(2000, 1, 1),
            revision_date: Date.new(2000, 1, 1),
            expiration_date: Date.new(2099, 1, 1),
            preview?: false,
            patent: flexmock("patent", certificate_number: "certificate_number", expiry_date: Date.new(2099, 12, 31)),
            price_public: price_public,
            name: "name",
            size: "size",
            iksnr: "iksnr",
            ikscd: "ikscd",
            sl_generic_type: "sl_generic_type",
            seqnr: "seqnr",
            pointer: "pointer",
            narcotic?: nil,
            ddd_price: "ddd_price",
            sl_entry: "sl_entry",
            atc_class: atc_class,
            name_base: "name_base",
            ikskey: "ikskey",
            limitation_text: limitation_text,
            production_science: "production_science",
            shortage_state: "shortage_state",
            shortage_link: "shortage_link",
            parallel_import: "parallel_import",
            ith_swissmedic: "ith_swissmedic",
            index_therapeuticus: "index_therapeuticus",
            price_exfactory: "price_exfactory",
            deductible: "deductible")
          @component = ODDB::View::Rss::Package.new([@model], @session)
        end

        def test_to_html
          retrieve_from_index = flexmock("retrieve_from_index", language: "language")
          cache = flexmock("cache", retrieve_from_index: [retrieve_from_index])
          flexmock(ODBA, cache: cache)
          context = flexmock("context", html: "html")
          expected = %(<?xml version="1.0" encoding="UTF-8"?>
<rss version="2.0"
  xmlns:content="http://purl.org/rss/1.0/modules/content/"
  xmlns:dc="http://purl.org/dc/elements/1.1/"
  xmlns:trackback="http://madskills.com/public/xml/rss/module/trackback/"
  xmlns:itunes="http://www.itunes.com/dtds/podcast-1.0.dtd">
  <channel>
    <title>lookup</title>
    <link>_event_url</link>
    <description>lookup</description>
    <language>language</language>
    <image>
      <url>resource</url>
      <title>lookup</title>
      <link>_event_url</link>
    </image>
    <item>
      <title>lookup: name, size, price_public, +1.0%</title>
      <link>_event_url</link>
      <description>html</description>
      <author>ODDB.org</author>
      <pubDate>Thu, 03 Feb 2011 00:00:00 -0000</pubDate>
      <guid isPermaLink="true">_event_url</guid>
      <dc:date>2011-02-03T00:00:00Z</dc:date>
    </item>
  </channel>
</rss>)
          assert_equal(expected, @component.to_html(context))
        end
      end
    end # Interactions
  end # View
end # ODDB
