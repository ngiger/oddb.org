#!/usr/bin/env ruby

# View::Hospitals::CenteredSearchForm -- oddb -- 15.02.2005 -- jlang@ywesee.com, usenguel@ywesee.com

require "view/centeredsearchform"

module ODDB
  module View
    module Hospitals
      class CenteredSearchComposite < View::CenteredSearchComposite
        COMPONENTS = {
          [0, 0]	=>	:language_chooser,
          [0, 1]	=>	View::CenteredSearchForm,
          [0, 2]	=>	"hospitals_search_explain",
          [0, 3]	=>	View::CenteredNavigation,
          [0, 5, 0]	=>	:hospitals_count,
          [0, 5, 1]	=>	"hospital_count_text",
          [0, 5, 2]	=>	"comma_separator",
          [0, 5, 6]	=>	"database_last_updated_txt",
          [0, 5, 7]	=>	:database_last_updated,
          [0, 6]	=>	:legal_note,
          [0, 7]	=>	:paypal
        }
        CSS_MAP = {
          [0, 0, 1, 8]	=>	"list center"
        }
        COMPONENT_CSS_MAP = {}
        def hospitals_count(model, session)
          @session.hospital_count.to_s << "&nbsp;"
        end
      end

      class GoogleAdSenseComposite < View::GoogleAdSenseComposite
        CONTENT = CenteredSearchComposite
        GOOGLE_CHANNEL = "1634362463"
      end
    end
  end
end
