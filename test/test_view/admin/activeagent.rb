#!/usr/bin/env ruby

# ODDB::View::Admin::TestActiveAgent -- oddb.org -- 03.06.2011 -- mhatakeyama@ywesee.com
$: << File.expand_path("../..", File.dirname(__FILE__))
$: << File.expand_path("../../../src", File.dirname(__FILE__))

require "stub/odba"
require "minitest/autorun"
require "flexmock/minitest"
require "model/activeagent"
require "view/additional_information"
require "view/admin/activeagent"

module ODDB
  module View
    module Admin
      class TestActiveAgentInnerComposite < Minitest::Test
        def setup
          @lnf = flexmock("lookandfeel",
            lookup: "lookup",
            language: "language")
          @session = flexmock("session",
            lookandfeel: @lnf,
            error: "error")
          dose = flexmock("dose", qty: "qty", unit: "unit")
          substance = flexmock("substance", language: "language")
          @model = flexmock("model", substance: substance, dose: dose)
          @composite = ODDB::View::Admin::ActiveAgentInnerComposite.new(@model, @session)
        end

        def test_substance
          assert_equal("language", @composite.substance(@model, @session))
        end
      end

      class TestActiveAgentForm < Minitest::Test
        def setup
          @lnf = flexmock("lookandfeel",
            lookup: "lookup",
            attributes: {},
            base_url: "base_url")
          @session = flexmock("session",
            lookandfeel: @lnf,
            error: "error",
            warning?: nil,
            error?: nil)
          @modle = flexmock("model")
          @form = ODDB::View::Admin::ActiveAgentForm.new(@model, @session)
        end

        def test_init
          assert_nil(@form.init)
        end
      end

      class TestActiveAgentComposite < Minitest::Test
        def setup
          @app = flexmock("app")
          @lnf = flexmock("lookandfeel",
            lookup: "lookup",
            language: "language")
          @session = flexmock("session",
            lookandfeel: @lnf,
            app: @app,
            error: "error")
          parent = flexmock("parent", name: "name")
          substance = flexmock("substance", language: "language")
          dose = flexmock("dose", qty: "qty", unit: "unit")
          @model = flexmock("model",
            parent: parent,
            pointer_descr: "pointer_descr",
            substance: substance,
            dose: dose)
          @composite = ODDB::View::Admin::ActiveAgentComposite.new(@model, @session)
        end

        def test_agent_name
          assert_equal("name&nbsp;-&nbsp;pointer_descr", @composite.agent_name(@model, @session))
        end
      end

      class RootActiveAgentComposite < ODDB::View::Admin::ActiveAgentComposite
        class RootSequenceAgents
          def initialize(model, session, other)
          end
        end
      end

      class TestRootActiveAgentComposite < Minitest::Test
        def setup
          @app = flexmock("app")
          @lnf = flexmock("lookandfeel",
            lookup: "lookup",
            attributes: {},
            base_url: "base_url")
          @session = flexmock("session",
            lookandfeel: @lnf,
            app: @app,
            error: "error",
            warning?: nil,
            error?: nil)
          parent = flexmock("parent", name: "name")
          active_agent = ODDB::ActiveAgent.new("active_agent")
          inactive_agent = ODDB::InactiveAgent.new("inactive_agent")
          package = flexmock("package", swissmedic_source: {"swissmedic_source" => "x"})
          sequence = flexmock("sequence",
            inactive_agents: [inactive_agent],
            active_agents: [active_agent],
            packages: {"key" => package})
          dose = flexmock("dose", qty: "qty", unit: "unit")
          @model = flexmock("model",
            parent: parent,
            pointer_descr: "pointer_descr",
            sequence: sequence,
            dose: dose)
          @composite = ODDB::View::Admin::RootActiveAgentComposite.new(@model, @session)
        end

        def test_active_agents
          assert_kind_of(ODDB::View::Admin::RootActiveAgentComposite::RootSequenceAgents, @composite.active_agents(@model, @session))
        end
      end
    end # Admin
  end # View
end # ODDB
