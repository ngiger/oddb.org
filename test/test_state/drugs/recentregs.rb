#!/usr/bin/env ruby

# ODDB::State::Drugs::TestRecentRegs -- oddb.org -- 23.06.2011 -- mhatakeyama@ywesee.com

$: << File.expand_path("../../../src", File.dirname(__FILE__))

require "state/drugs/global"
module ODDB
  module State
    module Drugs
      class RecentRegs < ODDB::State::Drugs::Global
      end
    end
  end
end

require "minitest/autorun"
require "flexmock/minitest"
require "state/drugs/recentregs"

module ODDB
  module State
    module Drugs
      class TestPackageMonth < Minitest::Test
        def setup
          galenic_form = flexmock("galenic_form", language: "language", galenic_group: "galenic_group")
          @registration = flexmock("registration", name_base: "name_base")
          package = flexmock("package",
            generic_type: "generic_type",
            galenic_forms: [galenic_form],
            comparable_size: "comparable_size",
            expired?: nil,
            name_base: "name_base",
            dose: "dose",
            company: "company",
            out_of_trade: false,
            sl_generic_type: :original,
            registration: @registration,
            sl_entry: false)
          @user = flexmock("user", name: "name")
          @lnf = flexmock("lookandfeel", lookup: "lookup", enabled?: false)
          @session = flexmock("session",
            user: @user,
            language: "language",
            request_path: "request_path",
            lookandfeel: @lnf)
          @registration.should_receive(:each_package).and_yield(package)
          @month = ODDB::State::Drugs::RecentRegs::PackageMonth.new("date", [@registration], @session)
        end

        def test_package_count
          assert_equal(1, @month.package_count)
        end
      end

      class TestRecentRegs < Minitest::Test
        def setup
          log_group = flexmock("log_group",
            newest_date: Time.local(2011, 2, 3),
            years: [2011],
            months: [2])
          @app = flexmock("app", log_group: log_group)
          @lnf = flexmock("lookandfeel", lookup: "lookup", enabled?: false)
          @user = flexmock("user", name: "name")
          @session = flexmock("session",
            app: @app,
            user: @user,
            lookandfeel: @lnf,
            user_input: nil,
            language: "language",
            request_path: "request_path")
          @model = flexmock("model")
          galenic_form = flexmock("galenic_form", language: "language", galenic_group: "galenic_group")
          @registration = flexmock("registration", name_base: "name_base")
          package = flexmock("package",
            generic_type: "generic_type",
            galenic_forms: [galenic_form],
            comparable_size: "comparable_size",
            expired?: nil,
            name_base: "name_base",
            dose: "dose",
            company: "company",
            out_of_trade: false,
            registration: @registration,
            sl_generic_type: :original,
            sl_entry: false)
          @registration.should_receive(:each_package).and_yield(package)
          cache = flexmock("cache", retrieve_from_index: [@registration])
          flexmock(ODBA, cache: cache)
          @state = ODDB::State::Drugs::RecentRegs.new(@session, @model)
        end

        def test_regs_by_month
          assert_equal([@registration], @state.regs_by_month(Time.local(2011, 2, 3)))
        end

        def test_create_package_month
          assert_kind_of(ODDB::State::Drugs::RecentRegs::PackageMonth, @state.create_package_month(Time.local(2011, 2.3)))
        end

        def test_init
          assert_equal([2], @state.init)
        end

        def test_init__user_input
          skip "Don't know how to handle NoMethodError: undefined method `assertions' for #<FlexMock::TestUnitFrameworkAdapter"
          flexmock(@session) do |s|
            s.should_receive(:user_input).with(:year).once.and_return(2011)
            s.should_receive(:user_input).with(:month).once.and_return(2)
          end
          assert_equal([2], @state.init)
        end
      end
    end # Drugs
  end # State
end # ODDB
