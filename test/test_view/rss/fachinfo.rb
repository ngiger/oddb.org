#!/usr/bin/env ruby

# ODDB::View::Rss::TestFachinfo -- oddb.org -- 22.06.2011 -- mhatakeyama@ywesee.com

$: << File.expand_path("../../../src", File.dirname(__FILE__))

require "minitest/autorun"
require "flexmock/minitest"
require "view/rss/fachinfo"
require "model/fachinfo"
require "util/today"
module ODDB
  module View
    module Rss
      class TestFachinfoItem < Minitest::Test
        def setup
          @lnf = flexmock("lookandfeel", lookup: "lookup")
          @session = flexmock("session",
            lookandfeel: @lnf,
            language: "language")
          language = flexmock("language", chapter_names: ["chapter_name"], empty?: true)
          flexmock(language, language: language)
          @model = flexmock("model", language: language)
          @composite = ODDB::View::Rss::FachinfoItem.new(@model, @session)
        end

        def test_init
          assert_equal([], @composite.init)
        end
      end

      class TestFachinfo < Minitest::Test
        def setup
          @year = 2011
          @lnf = flexmock("lookandfeel",
            lookup: "lookup",
            _event_url: "_event_url",
            resource: "resource",
            attributes: {})
          @session = flexmock("session",
            lookandfeel: @lnf,
            language: "language")
          @document = flexmock("document",
            is_a?: true,
            chapter_names: ["chapter_name"],
            empty?: true)
          @model = flexmock("model",
            localized_name: "localized_name",
            language: @document,
            pointer: "pointer",
            revision: Time.utc(@year, 2, 3),
            iksnrs: ["iksnrs"],
            odba_store: true)
          @component = ODDB::View::Rss::Fachinfo.new([@model], @session)
          @expected_2011 = %(<?xml version="1.0" encoding="UTF-8"?>
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
      <title>localized_name</title>
      <link>_event_url</link>
      <description>html</description>
      <author>ODDB.org</author>
      <pubDate>Thu, 03 Feb #{@year} 00:00:00 -0000</pubDate>
      <guid isPermaLink="true">_event_url</guid>
      <dc:date>#{@year}-02-03T00:00:00Z</dc:date>
    </item>
  </channel>
</rss>)
          @no_items = "<?xml version=\"1.0\" encoding=\"UTF-8\"?>
<rss version=\"2.0\"
  xmlns:content=\"http://purl.org/rss/1.0/modules/content/\"
  xmlns:dc=\"http://purl.org/dc/elements/1.1/\"
  xmlns:trackback=\"http://madskills.com/public/xml/rss/module/trackback/\"
  xmlns:itunes=\"http://www.itunes.com/dtds/podcast-1.0.dtd\">
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
  </channel>
</rss>"
        end

        def test_to_html_after_last_year
          @@today = Date.new(@year + 1, 2, 16)
          context = flexmock("context", html: "html")
          assert_equal(@expected_2011, @component.to_html(context), "should not item of last year (2011)")
        end

        def test_to_html_older_last_year
          @@today = Date.new(2013, 1, 1)
          context = flexmock("context", html: "html")
          assert_equal(@no_items, @component.to_html(context), "should not contain any items")
        end

        def test_to_html_year_2011
          @@today = Date.new(2015, 1, 1)
          context = flexmock("context", html: "html")
          container = nil
          @component = ODDB::View::Rss::Fachinfo.new([@model], @session, container, @year)
          assert_equal(@expected_2011, @component.to_html(context), "should not item of 2011")
        end

        def test_to_html_raise_rrror
          @@today = Date.new(2015, 1, 1)
          container = nil
          @model = flexmock("model",
            localized_name: "localized_name",
            language: @document,
            pointer: "pointer",
            revision: Time.utc(@year, 2, 3),
            odba_store: true)
          @raised_no_method_error = false
          @model.should_receive(:iksnrs).and_return { [] }
          @component = ODDB::View::Rss::Fachinfo.new([@model], @session, container, @year)
          context = flexmock("context", html: "html")
          res = @component.to_html(context)
          assert(res.is_a?(String), "should not raise an error")
        end
      end
    end # Interactions
  end # View
end # ODDB
