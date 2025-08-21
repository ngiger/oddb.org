#!/usr/bin/env ruby

# ODDB::View::Interactions::Result -- oddb.org -- 29.02.2012 -- mhatakeyama@ywesee.com
# ODDB::View::Interactions::Result -- oddb.org -- 26.05.2004 -- mhuggler@ywesee.com

require "view/form"
require "view/publictemplate"
require "view/interactions/resultlist"
require "view/searchbar"
require "view/logohead"

module ODDB
  module View
    module Interactions
      # class User < SBSM::KnownUser; end
      # class UnknownUser < SBSM::UnknownUser; end
      # class AdminUser < View::Drugs::User; end
      # class CompanyUser < View::Drugs::User; end
      class ResultForm < View::Form
        COLSPAN_MAP	= {
          [0, 2]	=> 2,
          [0, 3]	=> 2
        }
        COMPONENTS = {
          [0, 0]	=>	:title_found,
          [0, 1]	=>	"add_to_interaction",
          [1, 1, 0]	=>	:search_query,
          [1, 1, 1]	=>	:submit,
          [0, 2]	=>	View::Interactions::ResultList,
          [0, 3]	=>	:interaction_basket
        }
        CSS_CLASS = "composite"
        EVENT = :search
        FORM_METHOD = "GET"
        SYMBOL_MAP = {
          search_query: View::SearchBar
        }
        CSS_MAP = {
          [0, 0] =>	"result-found",
          [0, 1] =>	"list",
          [1, 1]	=>	"search",
          [0, 3]	=>	"list bg"
        }
        def interaction_basket(model, session)
          get_event_button(:interaction_basket, substance_ids: @session.interaction_basket_ids)
        end

        def interaction_basket_link(model, session)
          link = HtmlGrid::Link.new(:interaction_basket, model, session, self)
          link.href = @session.interaction_basket_link
          link.label = true
          link
        end

        def title_found(model, session)
          if session.state.respond_to?(:object_count)
            query = session.persistent_user_input(:search_query)
            @lookandfeel.lookup(:title_found, query, session.state.object_count)
          end
        end
      end

      class Result < View::ResultTemplate
        CONTENT = View::Interactions::ResultForm
      end

      class EmptyResultForm < HtmlGrid::Form
        COMPONENTS = {
          [0, 0, 0]	=>	:search_query,
          [0, 0, 1]	=>	:submit,
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
        CONTENT = View::Interactions::EmptyResultForm
      end
    end
  end
end
