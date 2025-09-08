#!/usr/bin/env ruby

# View::Pager -- oddb -- 28.08.2003 -- ywesee@ywesee.com

require "htmlgrid/link"
require "htmlgrid/list"

module ODDB
  module View
    class Pager < HtmlGrid::List
      BACKGROUND_SUFFIX = ""
      COMPONENTS = {
        [0, 0]	=>	:number_link
      }
      CSS_CLASS = "pager right"
      CSS_HEAD_MAP = {
        [0, 0]	=>	"pager-head"
      }
      CSS_MAP = {
        [0, 0]	=>	"pager"
      }
      OFFSET_STEP = [1, 0]
      SORT_DEFAULT = :to_i
      SORT_HEADER = false
      attr_accessor :event, :arguments
      def initialize(model, session, container = nil,
        event = :result, args = {})
        @event = event
        @arguments = args
        super(model, session, container)
      end

      def init
        @page = @session.state.page
        super
      end

      def compose_header(offset)
        @grid.add(page_number(@model, @session), *offset)
        @grid.add_style("pager-head", *offset)
        offset = resolve_offset(offset, self.class::OFFSET_STEP)
        if @page != @model.first
          link = page_link(:pager_back, @page.previous)
          @grid.add(link, *offset)
        end
        resolve_offset(offset, self.class::OFFSET_STEP)
      end

      def compose_footer(offset)
        if @page != @model.last
          link = page_link(:pager_fwd, @page.next)
          link.value = @lookandfeel.lookup(:pager_fwd)
          @grid.add(link, *offset)
        end
      end

      def to_html(context)
        init
        super
      end

      private

      def number_link(model, session)
        page_link(:to_s, model)
      end

      def page_link(key, page)
        if page != @session.state.page
          link = HtmlGrid::Link.new(key, page, @session, self)
          link.value = page.send(key) if page.respond_to?(key)
          link.set_attribute("class", "pager")
          values = @arguments.merge({
            page: page.to_s
          })
          link.href = @lookandfeel._event_url(@event, values)
          link
        else
          page.send(key)
        end
      end

      def page_number(model, session)
        page_now = session.state.page
        @lookandfeel.lookup(:page_number, page_now, model.size)
      end
    end
  end
end
