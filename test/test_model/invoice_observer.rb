#!/usr/bin/env ruby

# ODDB::TestInvoiceObserver -- oddb.org -- 29.06.2011 -- mhatakeyama@ywesee.com

$: << File.expand_path("../../src", File.dirname(__FILE__))

require "minitest/autorun"
require "flexmock/minitest"
require "model/invoice_observer"
require "odba"

module ODDB
  class StubInvoiceObserver
    include ODDB::InvoiceObserver
    def odba_store
      "odba_store"
    end
  end

  class TestInvoiceObserver < Minitest::Test
    def setup
      @observer = ODDB::StubInvoiceObserver.new
    end

    def test_add_invoice
      flexmock(ODBA.cache,
        next_id: 123,
        store: "store")
      invoice = flexmock("invoice",
        :marshal_dump => "marshal_dump",
        :user_pointer= => nil,
        :odba_isolated_store => "odba_isolated_store")
      assert_equal(invoice, @observer.add_invoice(invoice))
    end

    def test_contact
      @observer.instance_eval do
        @name_first = "name_first"
        @name = "name"
      end
      assert_equal("name_first name", @observer.contact)
    end

    def test_invoice
      flexmock(ODBA.cache,
        next_id: 123,
        store: "store")
      invoice = flexmock("invoice",
        :marshal_dump => "marshal_dump",
        :user_pointer= => nil,
        :odba_isolated_store => "odba_isolated_store",
        :oid => 123)
      @observer.add_invoice(invoice)

      assert_equal(invoice, @observer.invoice(123))
    end

    def test_invoice_email
      flexmock(@observer, email: "email")
      assert_equal("email", @observer.invoice_email)
    end

    def test_remove_invoice
      flexmock(ODBA.cache,
        next_id: 123,
        store: "store")
      invoice = flexmock("invoice",
        :marshal_dump => "marshal_dump",
        :user_pointer= => nil,
        :odba_isolated_store => "odba_isolated_store",
        :oid => 123)
      @observer.add_invoice(invoice)

      assert_equal(invoice, @observer.remove_invoice(invoice))
    end
  end
end # ODDB
