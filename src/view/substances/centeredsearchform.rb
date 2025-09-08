#!/usr/bin/env ruby

# View::Substances::CenteredSearchForm -- oddb -- 23.08.2004 -- mhuggler@ywesee.com

require "view/centeredsearchform"
require "view/language_chooser"

module ODDB
  module View
    module Substances
      class CenteredSearchComposite < View::CenteredSearchComposite
        COMPONENTS = {
          [0, 0]	=>	:language_chooser,
          [0, 1]	=>	View::CenteredSearchForm,
          [0, 2]	=>	"substance_search_explain",
          [0, 4]	=>	View::CenteredNavigation,
          [0, 5, 3]	=>	:substance_count,
          [0, 5, 4]	=>	"substance_count_text",
          [0, 5, 5]	=>	"comma_separator",
          [0, 5, 6]	=>	"database_last_updated_txt",
          [0, 5, 7]	=>	:database_last_updated,
          [0, 6]	=>	:legal_note,
          [0, 7]	=>	:paypal
        }
        CSS_MAP = {
          [0, 0, 1, 8]	=>	"list center"
        }
        COMPONENT_CSS_MAP = {
          [0, 6]	=>	"legal-note"
        }
        def substance_count(model, session)
          @session.app.substance_count
        end
      end
    end
  end
end
