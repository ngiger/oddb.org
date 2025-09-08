#!/usr/bin/env ruby

# View::Companies::CenteredSearchForm -- oddb -- 07.09.2004 -- mhuggler@ywesee.com

require "view/centeredsearchform"
require	"view/centeredsearchform"

module ODDB
  module View
    module Companies
      class CenteredSearchComposite < View::CenteredSearchComposite
        COMPONENTS = {
          [0, 0]	=>	:language_chooser,
          [0, 1]	=>	View::CenteredSearchForm,
          [0, 2]	=>	"companies_search_explain",
          [0, 3]	=>	View::CenteredNavigation,
          [0, 4, 0]	=>	:company_count,
          [0, 4, 1]	=>	"company_count_text",
          [0, 4, 2]	=>	"comma_separator",
          [0, 4, 3]	=>	"database_last_updated_txt",
          [0, 4, 4]	=>	:database_last_updated,
          [0, 5]	=>	:legal_note,
          [0, 6]	=>	:paypal
        }
        CSS_MAP = {
          [0, 0, 1, 7]	=>	"list center"
        }
        COMPONENT_CSS_MAP = {
          [0, 5]	=>	"legal-note"
        }
        def company_count(model, session)
          @session.app.company_count.to_s << "&nbsp;"
        end
      end

      class GoogleAdSenseComposite < View::GoogleAdSenseComposite
        CONTENT = CenteredSearchComposite
        GOOGLE_CHANNEL = "7502058606"
      end
    end
  end
end
