#!/usr/bin/env ruby

# ODDB::View::Drugs::Result -- oddb.org -- 01.03.2012 -- mhatakeyama@ywesee.com
# ODDB::View::Drugs::Result -- oddb.org -- 03.03.2003 -- andy@jetnet.ch

require "view/form"
require "view/resulttemplate"
require "view/drugs/resultlist"
require "view/resultfoot"
require "view/searchbar"
require "view/logohead"
require "view/drugs/rootresultlist"
require "view/pager"
require "view/user/export"
require "sbsm/user"

module ODDB
  module View
    module Drugs
      class UnknownUser < SBSM::UnknownUser; end

      class DivExportCSV < HtmlGrid::DivForm
        include View::User::Export
        COMPONENTS = {
          [0, 0]	=>	:new_feature,
          [1, 0]	=>	:example,
          [2, 0]	=>	:submit
        }
        LEGACY_INTERFACE = false
        def init
          super
          search_query = @session.persistent_user_input(:search_query)
          if search_query.respond_to?(:gsub)
            search_query.gsub("/", "%2F")
          else
            ""
          end
          {
            zone: @session.zone,
            search_query: search_query,
            search_type: @session.persistent_user_input(:search_type)
          }
        end

        def example(model)
          super("Inderal.Preisvergleich.csv")
        end

        def hidden_fields(context)
          hidden = super
          [:search_query, :search_type].each { |key|
            hidden << context.hidden(key.to_s,
              @session.persistent_user_input(key))
          }
          hidden
        end

        def new_feature(model)
          span = HtmlGrid::Span.new(model, @session, self)
          span.value = @lookandfeel.lookup(:new_feature)
          span.set_attribute("style", "color: red; margin: 5px; font-size: 8pt;")
          # span.set_attribute('style','color: red; margin: 5px; font-size: 11pt;')
          span
        end
      end

      class ResultComposite < HtmlGrid::Composite
        include ResultFootBuilder
        COLSPAN_MAP	= {}
        COMPONENTS = {}
        CSS_CLASS = "composite"
        EVENT = :search
        FORM_METHOD = "GET"
        DEFAULT_LISTCLASS = View::Drugs::ResultList
        ROOT_LISTCLASS = View::Drugs::RootResultList
        SYMBOL_MAP = {}
        def init
          y = 0
          if @lookandfeel.enabled?(:explain_sort, false)
            components.store([0, y], "explain_sort")
            css_map.store([0, y], "navigation")
            colspan_map.store([0, y], 2)
            y += 1
          end
          if @lookandfeel.enabled?(:oekk_structure, false)
            components.store([0, y], :explain_colors)
            css_map.store([0, y], "explain")
            colspan_map.store([0, y], 2)
            y += 1
          end
          colspan_map.store([0, y], 2)
          components.store([0, y], @session.allowed?("edit", "org.oddb.drugs") \
                                  ? self.class::ROOT_LISTCLASS
                                  : self.class::DEFAULT_LISTCLASS)
          if @lookandfeel.enabled?(:print, false)
            components.store([1, 0], :print)
          else
            colspan_map.store([0, 0], 2)
          end
          code = @session.persistent_user_input(:code)
          unless @model.respond_to?(:overflow?) && @model.overflow? \
                 && (code.nil? || !@model.any? { |atc| atc.code == code })
            y += 1
            components.store([0, y], :result_foot)
            colspan_map.store([0, y], 2)
          end
          super
        end

        def search_drug_form(model, session = @session)
          div = HtmlGrid::Div.new(model, @session, self)
          div.css_class = "right search_drug_form"
          div.set_attribute("id", "search_drug_form")
          div.value = SelectSearchForm.new(model, @session)
          div
        end

        def explain_colors(model, session = @session)
          comps = {
            [0, 0]	=>	:explain_original,
            [0, 1]	=>	:explain_generic,
            [0, 2]	=>	"explain_unknown"
          }
          ExplainResult.new(model, @session, self, comps)
        end

        def print(model, session = @session)
          link = HtmlGrid::Link.new(:print, model, @session, self)
          link.set_attribute("onClick", "window.print();")
          link.href = ""
          link
        end

        def title_found(model, session = @session)
          query = @session.persistent_user_input(:search_query)
          @lookandfeel.lookup(:title_found, query, model.package_count)
        end
      end

      class Result < View::PrivateTemplate
        CONTENT = ResultComposite
        SNAPBACK_EVENT = :result
        SEARCH_HEAD = ODDB::View::SelectSearchForm
        JAVASCRIPTS = ["bit.ly"]
        def init
          if @lookandfeel.disabled?(:search)
            components.delete [1, 1]
          end
          super
        end

        def backtracking(model, session = @session)
          breadcrumbs = []
          if @lookandfeel.enabled?(:home)
            dv = HtmlGrid::Span.new(model, @session, self)
            dv.css_class = "breadcrumb"
            dv.value = "&lt;"
            span1 = HtmlGrid::Span.new(model, @session, self)
            span1.css_class = "breadcrumb bold"
            link1 = HtmlGrid::Link.new(:back_to_home, model, @session, self)
            link1.href = @lookandfeel._event_url(:home)
            link1.css_class = "list"
            span1.value = link1
            breadcrumbs.push span1, dv
          end
          span2 = HtmlGrid::Span.new(model, @session, self)
          span2.css_class = "breadcrumb"
          query = @session.persistent_user_input(:search_query).gsub("/", "%2F")
          span2.value = @lookandfeel.lookup(:list_for, query, model.package_count)
          span3 = HtmlGrid::Span.new(model, @session, self)
          span3.css_class = "breadcrumb"
          span3.value = "&ndash;"
          url = @lookandfeel.event_url(:sort, {sortvalue: :dsp})
          link = HtmlGrid::Link.new(:dsp_sort, model, @session, self)
          link.href = url
          breadcrumbs.push span2, span3, link
          breadcrumbs
        end
      end

      class EmptyResultComposite < HtmlGrid::Composite
        COMPONENTS = {
          [0, 0]	=>	SelectSearchForm,
          [0, 1]	=>	:title_none_found,
          [0, 2]	=>	"e_empty_result",
          [0, 3]	=>	"explain_search"
        }
        CSS_MAP = {
          [0, 0]	=>	"search",
          [0, 1]	=>	"th",
          [0, 2, 1, 2]	=>	"list atc"
        }
        CSS_CLASS = "composite"
        def title_none_found(model, session)
          query = session.persistent_user_input(:search_query)
          @lookandfeel.lookup(:title_none_found, query)
        end
      end

      class EmptyResult < View::ResultTemplate
        CONTENT = View::Drugs::EmptyResultComposite
      end
    end
  end
end
