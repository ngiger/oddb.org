#!/usr/bin/env ruby

# View::PrintTemplate -- ODDB -- 09.03.2004 -- hwyss@ywesee.com

require "view/publictemplate"

module ODDB
  module View
    module Print
      def print(model, session = @session, key = :print)
        link = HtmlGrid::Link.new(key, model, session, self)
        link.set_attribute("title", @lookandfeel.lookup(:print_title))
        args = {
          pointer: model.pointer
        }
        link.href = @lookandfeel._event_url(:print, args)
        link
      end

      def print_edit(model, session = @session, key = :print)
        print(model, session, :print_edit)
      end
    end

    class PrintTemplate < View::PublicTemplate
      COMPONENTS = {
        [0, 0]	=>	:head,
        [0, 1]	=>	:content
      }
      def init
        @attributes["onload"] = %(require(["dojo/domReady!"], function(){
						'window.print();'
});
)
        super
      end

      def head(model, session = @session)
        @lookandfeel.lookup(:print_head)
      end

      def css_link(context, path = @lookandfeel.resource_global(:css_print))
        super
      end
    end

    module PrintComposite
      COLSPAN_MAP = {}
      COMPONENTS = {
        [0, 0]	=>	:print_type,
        [0, 1]	=>	:name,
        [0, 2]	=>	:company_name,
        [0, 3] =>	:document
      }
      CSS_MAP = {
        [0, 1] => "print big",
        [0, 2]	=> "list right"
      }
      def name(model, session = @session)
        if (document = model.send(session.language))
          document.name
        end
      end

      def document(model, session = @session)
        if (document = model.send(session.language))
          self.class::INNER_COMPOSITE.new(document, session, self)
        end
      end

      def print_type(model, session = @session)
        @lookandfeel.lookup(self.class::PRINT_TYPE)
      end
    end
  end
end
