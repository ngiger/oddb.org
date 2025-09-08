#!/usr/bin/env ruby

# ODDB::View::Doctors::DocotorList -- oddb.org -- 31.10.2011 -- mhatakeyama@ywesee.com
# ODDB::View::Doctors::DocotorList -- oddb.org -- 26.05.2003 -- jlang@ywesee.com

require "htmlgrid/value"
require "htmlgrid/link"
require "htmlgrid/urllink"
require "htmlgrid/list"
require "util/umlautsort"
require "view/pointervalue"
require "view/publictemplate"
require "view/alphaheader"
require "view/searchbar"
require "view/doctors/doctor"
require "view/form"

module ODDB
  module View
    module Doctors
      class DoctorList < HtmlGrid::List
        include AddressMap
        include VCardMethods
        COMPONENTS = {
          [0, 0]	=>	:name,
          [1, 0]	=>	:firstname,
          [2, 0]	=>	:tel,
          [3, 0]	=>	:praxis_address,
          [4, 0]	=>	:specialities,
          [5, 0]	=>	:map,
          [6, 0]	=>	:vcard
        }
        DEFAULT_CLASS = HtmlGrid::Value
        CSS_CLASS = "composite"
        CSS_MAP = {
          [0, 0, 7]	=>	"top list"
        }
        DEFAULT_HEAD_CLASS = "th"
        SORT_DEFAULT = :name
        SORT_REVERSE = false
        LEGACY_INTERFACE = false
        def init
          if @session.state.paged?
            extend(View::AlphaHeader)
          end
          super
        end

        def praxis_address(model)
          if (address = model.praxis_address)
            emails = model.email
            if !emails.is_a?(Array)
              emails = [emails]
            end
            (address.lines + emails).join("<br>")
          end
        end

        def map(doctor)
          if (address = doctor.praxis_address)
            super(address)
          end
        end

        def name(model)
          link = View::PointerLink.new(:name, model, @session, self)
          link.href = if ean = model.ean13 and ean.to_s.strip != ""
            @lookandfeel._event_url(:doctor, {ean: ean})
          else
            @lookandfeel._event_url(:doctor, {oid: model.oid})
          end
          link
        end

        def tel(model)
          if (address = model.praxis_address)
            address.fon.join("<br>")
          end
        end

        def specialities(model)
          spc = model.specialities
          spc.join("<br>") unless spc.nil?
        end

        def vcard(model)
          link = View::PointerLink.new(:vcard, model, @session, self)
          ean_or_oid = if ean = model.ean13 and ean.to_s.strip != ""
            ean
          else
            model.oid
          end
          link.href = @lookandfeel._event_url(:vcard, {doctor: ean_or_oid})
          link
        end
      end

      class DoctorsComposite < Form
        CSS_CLASS = "composite"
        COMPONENTS = {
          [0, 0, 0]	=>	:search_query,
          [0, 0, 1]	=>	:submit,
          [0, 1]	=>	DoctorList
        }
        EVENT = :search
        SYMBOL_MAP = {
          search_query: View::SearchBar,
          map: HtmlGrid::Link,
          vcard: HtmlGrid::Link
        }
        CSS_MAP = {
          [0, 0]	=> "right"
        }
      end

      class Doctors < View::ResultTemplate
        CONTENT = View::Doctors::DoctorsComposite
      end

      class EmptyResultForm < HtmlGrid::Form
        COMPONENTS = {
          [0, 0, 0]	=>	:search_query,
          [0, 0, 1]	=>	:submit,
          [0, 1]	=>	:title_none_found,
          [0, 2]	=>	"e_empty_result",
          [0, 3]	=>	"explain_search_doctor"
        }
        CSS_MAP = {
          [0, 0]	=>	"search",
          [0, 1]	=>	"th",
          [0, 2, 1, 2]	=>	"list atc"
        }
        CSS_CLASS = "composite"
        EVENT = :search
        FORM_METHOD = "GET"
        SYMBOL_MAP = {
          search_query: View::SearchBar
        }
        def title_none_found(model, session)
          query = session.persistent_user_input(:search_query)
          @lookandfeel.lookup(:title_none_found, query)
        end
      end

      class EmptyResult < View::PublicTemplate
        CONTENT = View::Doctors::EmptyResultForm
      end
    end
  end
end
