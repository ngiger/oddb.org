#!/usr/bin/env ruby

# ODDB::Invoice -- oddb.org -- 02.11.2011 -- mhatakeyama@ywesee.com
# ODDB::Invoice -- oddb.org -- 08.10.2004 -- mwalder@ywesee.com, rwaltert@ywesee.com

require "util/persistence"
require "util/today"

module ODDB
  class Invoice
    include Persistence
    attr_reader :items
    attr_accessor :currency, :user_pointer, :keep_if_unpaid, :yus_name
    def initialize
      super
      @items = {}
      @payment_received = false
      @unexpirable = false
    end

    def init(app)
      @pointer.append(@oid)
    end

    def item_by_text(text)
      @items.values.find { |item|
        item.text == text
      }
    end

    def create_item
      item = InvoiceItem.new
      @items.store(item.oid, item)
    end

    def deletable?
      !(@payment_received || @keep_if_unpaid) && expired?
    end

    def expired?(time = nil)
      @items.values.all? { |item| item.expired?(time) }
    end

    def item(oid)
      @items[oid]
    end

    def max_duration
      @items.values.collect { |item| item.duration }.compact.max
    end

    def total_brutto
      @items.values.inject(0) { |inj, item| inj + item.total_brutto }
    end

    def total_netto
      @items.values.inject(0) { |inj, item| inj + item.total_netto }
    end

    def types
      @items.values.collect { |item| item.type }.compact.uniq
    end

    def payment_received!
      @payment_received = true
    end

    def payment_received?
      @payment_received
    end

    def vat
      @items.values.inject(0) { |inj, item| inj + item.vat }
    end
  end

  class AbstractInvoiceItem
    attr_accessor :data, :duration, :expiry_time, :item_pointer,
      :price, :quantity, :text, :time, :type, :unit, :user_pointer, :yus_name,
      :vat_rate
    def initialize
      @quantity = 1.0
      @duration = 1
      @data = {}
    end

    def dup
      dup = super
      if @data
        dup.data = @data.dup
      end
      dup
    end

    def total_brutto
      total_netto * (1.0 + (@vat_rate.to_f / 100.0))
    end

    def total_brutto=(total)
      self.total_netto = (total / (1.0 + (@vat_rate.to_f / 100.0)))
    end

    def total_netto
      @quantity.to_f * @price.to_f
    end

    def total_netto=(total)
      @price = total.to_f / @quantity.to_f
    end

    def to_s
      @text.to_s
    end

    def vat
      total_netto * @vat_rate.to_f / 100.0
    end

    def values
      {
        data: @data,
        duration: @duration,
        expiry_time: @expiry_time,
        item_pointer: @item_pointer,
        price: @price,
        quantity: @quantity,
        text: @text,
        time: @time,
        type: @type,
        unit: @unit,
        yus_name: @yus_name,
        vat_rate: @vat_rate
      }
    end
  end

  class InvoiceItem < AbstractInvoiceItem
    include Persistence
    ODBA_SERIALIZABLE = ["@data"]
    attr_accessor :sequence
    def self.expiry_time(duration, time)
      time + (duration * 24 * 60 * 60)
    end

    def initialize
      super
      @quantity = 1
    end

    def expired?(time = nil)
      @time.nil? \
        || @expiry_time.nil? or
        begin
          exp = Date.new(@expiry_time.year, @expiry_time.month, @expiry_time.day)
          date = case time
          when Date
            time
          when Time
            Date.new(time.year, time.month, time.day)
          else
            @@today
          end
          date > exp
        end
    end

    def init(app)
      @pointer.append(@oid)
    end
  end
end
