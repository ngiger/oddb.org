#!/usr/bin/env ruby

# ODDB::State::TestNotify -- oddb.org -- 09.04.2012 -- yasaka@ywesee.com
# ODDB::State::TestNotify -- oddb.org -- 27.04.2011 -- mhatakeyama@ywesee.com

$: << File.expand_path("../../src", File.dirname(__FILE__))

require "minitest/autorun"
require "flexmock/minitest"
require "state/notify"
require "cgi"
require "view/resulttemplate"
require "view/notify"
require "model/package"

module ODDB
  module State
    class TestNotification < Minitest::Test
      def test_empty
        @notification = ODDB::State::Notify::Notification.new
        assert(@notification.empty?)
      end
    end

    class StubNotify
      include ODDB::State::Notify
      ITEM_TYPE = "item_type"
      CODE_KEY = "code_key"
      CONFIRM_STATE = self
      def initialize(session, model)
        @session = session
        @model = model
      end
    end

    class TestNotify < Minitest::Test
      def setup
        @lnf = flexmock("lookandfeel", lookup: "lookup")
        @session = flexmock("session", lookandfeel: @lnf)
        @model = flexmock("model")
        @notify = ODDB::State::StubNotify.new(@session, @model)
      end

      def test_init
        pointer = flexmock("pointer", resolve: "item")
        flexmock(@session, user_input: pointer)
        assert_equal("item", @notify.init)
      end

      def test_breakline
        expected = "aaa \nbbb \nccc"
        assert_equal(expected, @notify.breakline("aaa bbb ccc", 5))
      end

      def test_notify
        @notify.instance_eval do
          @errors = {}
          @passed_turing_test = true
        end
        user_input = {
          message: "message",
          name: "name",
          notify_sender: "notify_sender",
          notify_recipient: ["notify_recipient"],
          notify_message: "notify_message"
        }
        flexmock(@notify,
          user_input: user_input,
          error?: false,
          model: @model)
        @model.class.instance_eval do
          attr_accessor :name, :notify_sender, :notify_recipient, :notify_message
        end
        item = flexmock("item",
          pointer: "pointer",
          code_key: "code_key")
        flexmock(@model, item: item)
        flexmock(@lnf, _event_url: "_event_url")
        cgi = flexmock("cgi", html: "html")
        logger = flexmock("logger",
          log: "log",
          odba_store: "odba_store")
        flexmock(@session,
          cgi: cgi,
          notification_logger: logger)
        skip("Somebody moved Migel around without updating the corresponding test, here")
        assert_kind_of(ODDB::State::StubNotify, @notify.notify_send)
      end

      def test_notify__candidate
        @notify.instance_eval do
          @errors = {}
        end
        candidates = {"key" => "word"}
        user_input = {
          captcha: candidates,
          message: "message",
          name: "name",
          notify_sender: "notify_sender",
          notify_recipient: ["notify_recipient"],
          notify_message: "notify_message"
        }
        flexmock(@notify,
          user_input: user_input,
          error?: false,
          model: @model)
        @model.class.instance_eval do
          attr_accessor :name, :notify_sender, :notify_recipient, :notify_message
        end
        item = flexmock("item",
          pointer: "pointer",
          code_key: "code_key")
        flexmock(@model, item: item)
        flexmock(@lnf,
          _event_url: "_event_url",
          "captcha.valid_answer?": true)
        cgi = flexmock("cgi", html: "html")
        logger = flexmock("logger",
          log: "log",
          odba_store: "odba_store")
        flexmock(@session,
          cgi: cgi,
          notification_logger: logger)
        skip("Somebody moved Migel around without updating the corresponding test, here")
        assert_kind_of(ODDB::State::StubNotify, @notify.notify_send)
      end

      def test_notify_send__error
        flexmock(@notify,
          user_input: {},
          create_error: "create_error",
          error?: true)
        @notify.instance_eval("@errors = {}", __FILE__, __LINE__)
        flexmock(@model,
          :name= => nil,
          :notify_sender= => nil,
          :notify_recipient= => nil,
          :notify_message= => nil)
        assert_equal(@notify, @notify.notify_send)
      end
    end
  end # State
end # ODDB
