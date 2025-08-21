#!/usr/bin/env ruby

# View::ExternalLinks -- oddb -- 21.11.2005 -- hwyss@ywesee.com

module ODDB
  module View
    module ExternalLinks
      def contact_link(model, session = @session)
        link = NavigationLink.new(:contact_link,
          model, @session, self)
        link.href = @lookandfeel.lookup(:contact_href)
        link
      end

      def external_link(model, key)
        klass = if @lookandfeel.enabled?(:popup_links, false)
          HtmlGrid::PopupLink
        else
          HtmlGrid::Link
        end
        klass.new(key, model, @session, self)
      end

      def faq_link(model, session = @session)
        wiki_link(model, :faq_link, :faq_pagename)
      end

      def generic_definition(model, session)
        link = HtmlGrid::Link.new(:generic_definition, model, session, self)
        link.href = @lookandfeel.lookup(:generic_definition_url)
        link.set_attribute("class", "list")
        link
      end

      def help_link(model, session = @session)
        wiki_link(model, :help_link, :help_pagename)
      end

      def wiki_link(model, key, namekey)
        link = external_link(model, key)
        name = @lookandfeel.lookup(namekey)
        link.href = "http://wiki.oddb.org/wiki.php?pagename=#{name}"
        link
      end

      ## meddrugs_update, data_declaration and legal_note:
      ## extrawurst for just-medical
      def data_declaration(model, session = @session)
        wiki_link(model, :data_declaration, :datadeclaration_pagename)
      end

      def legal_note(model, session = @session)
        wiki_link(model, :legal_note, :legal_note_pagename)
      end

      def meddrugs_update(model, session = @session)
        link = NavigationLink.new(:meddrugs_update,
          model, @session, self)
        link.href = "https://www.med-drugs.ch/index.cfm?&content=meddrugsupdate"
        link.set_attribute("target", "_top")
        link
      end
    end
  end
end
