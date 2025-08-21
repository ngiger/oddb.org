#!/usr/bin/env ruby

# View::DescriptionList -- oddb -- 26.03.2003 -- aschrafl@ywesee.com

require "htmlgrid/value"
require "view/form"

module ODDB
  module View
    class DescriptionList < View::FormList
      CSS_CLASS = "composite"
      COMPONENTS = {
        [0, 0] => :description
      }
      DEFAULT_HEAD_CLASS = "subheading"
      SORT_HEADER = false
      SORT_DEFAULT = :description
      STRIPED_BG = true
      def description(model, session)
        klass = self.class::SYMBOL_MAP[:description]
        klass ||= HtmlGrid::Value
        component = klass.new(:description, model, session, self)
        component.value = model.description(@lookandfeel.language)
        component
      end

      private

      def sort_model
        if self.class::SORT_DEFAULT
          @model = @model.sort_by { |item|
            item.send(self.class::SORT_DEFAULT, @lookandfeel.language)
          }
        end
      end
    end
  end
end
