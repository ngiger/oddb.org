#!/usr/bin/env ruby

# ODDB::Stage::PageFacade -- oddb.org -- 17.02.2012 -- mhatakeyama@ywesee.com
# ODDB::Stage::PageFacade -- oddb.org -- 01.06.2004 -- mhuggler@ywesee.com
# require 'mathn'

module ODDB
  module State
    class PageFacade < Array
      attr_accessor :model
      def initialize(int)
        super()
        @int = int
      end

      def next
        PageFacade.new(@int.next)
      end

      def previous
        PageFacade.new(@int - 1)
      end

      def to_s
        @int.next.to_s
      end

      def to_i
        @int
      end

      def method_missing(name, *args, &block)
        @model.send(name, *args, &block)
      end

      def respond_to?(name)
        super || @model.respond_to?(name)
      end
    end

    class OffsetPageFacade < PageFacade
      attr_accessor :size, :offset
      def content
        "#{@offset.next} - #{@offset + @size}"
      end
    end

    module OffsetPaging
      PERSISTENT_RANGE = true
      ITEM_LIMIT = 100
      ITEM_SLACK = 20
      attr_reader :pages
      def init
        super
        @model = load_model
        @pages = []
        msize = @model.size
        num_pages = [((msize - ITEM_SLACK) / ITEM_LIMIT).to_i, 0].max.next
        num_pages.times { |pagenum|
          page = OffsetPageFacade.new(pagenum)
          offset = pagenum * ITEM_LIMIT
          size = ITEM_LIMIT
          if pagenum.next == num_pages
            size = msize - offset
          end
          page.offset = offset
          page.size = size
          page.concat(@model[offset, size])
          @pages.push(page)
        }
      end

      def filter(model)
        page
      end

      def page
        @page = @pages[@session.user_input(:page).to_i] if @pages
        @page ||= []
      end
    end
  end
end
