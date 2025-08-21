#!/usr/bin/env ruby

# ODDB::View::AlphaHeader -- oddb.org -- 29.02.2012 -- mhatakeyama@ywesee.com
# ODDB::View::AlphaHeader -- oddb.org -- 03.07.2003 -- hwyss@ywesee.com

module ODDB
  module View
    module AlphaHeader
      EMPTY_LIST_KEY = :choose_range
      def compose_header(offset = [0, 0])
        offset = super
        divider = false
        if @session.state.respond_to?(:interval)
          current_range = @session.state.interval
          @session.state.intervals.each { |range|
            @grid.add(divider, *offset) if divider
            divider = @lookandfeel.lookup(:navigation_divider)
            link = HtmlGrid::Link.new(:range, @model, @session, self)
            link.value = @lookandfeel.lookup(range.intern)
            unless range == current_range
              link.href = @lookandfeel._event_url(@session.direct_event,
                {"range" => range})
            end
            link.set_attribute("class", "subheading bold")
            @grid.add(link, *offset)
          }
          @grid.set_colspan(offset.at(0), offset.at(1), full_colspan)
          @grid.add_style("subheading bold", *offset)
          resolve_offset(offset, self.class::OFFSET_STEP)
        end
      end
    end
  end
end
