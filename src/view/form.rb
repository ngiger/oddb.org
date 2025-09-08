#!/usr/bin/env ruby

# View::Form -- oddb -- 14.03.2003 -- hwyss@ywesee.com

require "htmlgrid/form"
require "htmlgrid/formlist"
require "htmlgrid/inputtext"
require "util/today"

module ODDB
  module View
    module HiddenPointer
      private

      def hidden_fields(context)
        hidden = super
        if @model.respond_to?(:pointer)
          hidden << context.hidden("pointer", @model.pointer.to_s)
        end
        hidden << context.hidden("zone", @session.zone)
        hidden
      end
    end

    module FormMethods
      include View::HiddenPointer
      ACCEPT_CHARSET = "UTF-8"
      DEFAULT_CLASS = HtmlGrid::InputText
      EVENT = :update

      private

      def delete_item(model, session = @session)
        unless @model.is_a? Persistence::CreateItem
          button = HtmlGrid::Button.new(:delete, model, session, self)
          button.set_attribute("onclick", "form.event.value='delete'; form.submit();")
          button
        end
      end

      def delete_item_warn(model, warning)
        unless @model.is_a? Persistence::CreateItem
          button = HtmlGrid::Button.new(:delete, model, @session, self)
          warning = @lookandfeel.lookup(warning)
          script = "if(confirm('#{warning}')) "
          script << "{ form.event.value='delete'; form.submit(); }"
          button.set_attribute("onclick", script)
          button
        end
      end

      def post_event_button(event)
        button = HtmlGrid::Button.new(event, @model, @session, self)
        script = "this.form.event.value='" + event.to_s + "'; this.form.submit();"
        button.set_attribute("onclick", script)
        button
      end

      def get_event_button(event, params = {})
        button = HtmlGrid::Button.new(event, @model, @session, self)
        url = @lookandfeel._event_url(event, params)
        script = "document.location.href='#{url}';"
        button.set_attribute("onclick", script)
        button
      end
    end

    class Form < HtmlGrid::Form
      include FormMethods
    end

    class FormList < HtmlGrid::FormList
      include View::HiddenPointer
    end
  end
end
