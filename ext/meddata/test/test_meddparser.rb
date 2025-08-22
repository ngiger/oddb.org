#!/usr/bin/env ruby
# ODDB::MedData::TestFormatter -- oddb.org -- 05.07.2011 -- mhatakeyama@ywesee.com

$: << File.expand_path("../../../src", File.dirname(__FILE__))
$: << File.expand_path("../src", File.dirname(__FILE__))

require "minitest/autorun"
require "flexmock/minitest"
require "meddparser"

module ODDB
  module MedData
    class TestFormatter < Minitest::Test
      def setup
        @writer = flexmock("writer")
        @formatter = ODDB::MedData::Formatter.new(@writer)
      end

      def test_push_tablecell
        flexmock("tablehandler", next_cell: "next_cell")
        @formatter.instance_eval("@tablehandler = tablehandler", __FILE__, __LINE__)
        assert_equal("next_cell", @formatter.push_tablecell({}))
      end
    end

    class TestResultWriter < Minitest::Test
      def setup
        @writer = ODDB::MedData::ResultWriter.new
      end

      def test_extract_data
        tablehandler = flexmock("tablehandler", attributes: {"key" => "value"})
        child = flexmock("child", attributes: {"href" => "aaa$bbb$ccc$"})
        row = flexmock("row",
          children: [child],
          cdata: "cdata")
        flexmock(tablehandler).should_receive(:each_row).and_yield(row)
        @writer.instance_eval do
          @tablehandlers = [tablehandler]
          @dg_pattern = /value/
        end
        expected = {"bbb" => ["cdata", "cdata", "cdata"]}
        assert_equal(expected, @writer.extract_data)
      end

      def test_new_linkhandler
        flexmock("current_tablehandler", add_child: "add_child")
        @writer.instance_eval("@current_tablehandler = current_tablehandler", __FILE__, __LINE__)
        assert_equal("add_child", @writer.new_linkhandler("handler"))
      end

      def test_new_tablehandler
        assert_equal(["handler"], @writer.new_tablehandler("handler"))
      end

      def test_send_flowing_data
        flexmock("current_tablehandler", send_cdata: "send_cdata")
        @writer.instance_eval("@current_tablehandler = current_tablehandler", __FILE__, __LINE__)
        assert_equal("send_cdata", @writer.send_flowing_data("data"))
      end
    end

    class TestDetailWriter < Minitest::Test
      def setup
        @writer = ODDB::MedData::DetailWriter.new
      end

      def test_new_tablehandler
        assert_equal(["handler"], @writer.new_tablehandler("handler"))
      end

      def test_extract_data
        handler = flexmock("handler",
          attributes: [["key", "Table2"]],
          extract_cdata: "extract_cdata")
        @writer.new_tablehandler(handler)
        assert_equal("extract_cdata", @writer.extract_data("template"))
      end

      def test_send_flowing_data
        flexmock("current_tablehandler", send_cdata: "send_cdata")
        @writer.instance_eval("@current_tablehandler = current_tablehandler", __FILE__, __LINE__)
        assert_equal("send_cdata", @writer.send_flowing_data("data"))
      end
    end
  end # MedData
end # ODDB
