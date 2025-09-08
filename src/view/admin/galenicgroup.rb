#!/usr/bin/env ruby

# ODDB::View::Admin::GalenicGroup -- oddb.org -- 26.10.2011 -- mhatakeyama@jetnet.ch
# ODDB::View::Admin::GalenicGroup -- oddb.org -- 26.03.2003 -- andy@jetnet.ch

require "view/drugs/privatetemplate"
require "view/descriptionlist"
require "view/descriptionform"
require "view/pointervalue"
require "util/pointerarray"

module ODDB
  module View
    module Admin
      class GalenicForms < View::DescriptionList
        COMPONENTS = {
          [0, 0]	=>	:oid,
          [1, 0]	=>	:description,
          [2, 0]	=>	:de,
          [3, 0]	=>	:en,
          [4, 0]	=>	:fr,
          [5, 0]	=>	:lt
        }
        CSS_MAP = {
          [0, 0, 6]	=>	"list"
        }
        DEFAULT_CLASS = HtmlGrid::Value
        EVENT = :new_galenic_form
        SYMBOL_MAP = {
          description: View::PointerLink,
          oid: View::PointerLink
        }
        def oid(model, session)
          link = View::PointerLink.new(:oid, model, session)
          link.href = @lookandfeel._event_url(:galenic_form, [:goid, model.galenic_group.oid, :foid, model.oid])
          link
        end

        def description(model, session)
          link = View::PointerLink.new(:description, model, session)
          link.href = @lookandfeel._event_url(:galenic_form, [:goid, model.galenic_group.oid, :foid, model.oid])
          link
        end
      end

      class GalenicGroupForm < View::DescriptionForm
        COMPONENTS = {
          [2, 0]	=>	:route_of_administration
        }
        CSS_MAP = {
          [2, 0, 2]	=>	"list"
        }
        SYMBOL_MAP = {
          route_of_administration: HtmlGrid::Select
        }
      end

      class GalenicGroupComposite < HtmlGrid::Composite
        COMPONENTS = {
          [0, 0]	=>	"galenic_group",
          [0, 1]	=>	GalenicGroupForm,
          [0, 2]	=>	:galenic_forms
        }
        CSS_CLASS = "composite"
        CSS_MAP = {
          [0, 0]	=>	"th"
        }
        def galenic_forms(model, session)
          forms = if (galforms = model.galenic_forms)
            galforms.values
          else
            []
          end
          mdl = PointerArray.new(forms, model.pointer)
          View::Admin::GalenicForms.new(mdl, session, self) unless model.is_a?(Persistence::CreateItem)
        end
      end

      class GalenicGroup < View::Drugs::PrivateTemplate
        CONTENT = View::Admin::GalenicGroupComposite
        SNAPBACK_EVENT = :galenic_groups
      end
    end
  end
end
