#!/usr/bin/env ruby

# ODDB::State::Migel::Alphabetical -- oddb.org -- 12.01.2012 -- hwyss@ywesee.com
# ODDB::State::Migel::Alphabetical -- oddb.org -- 02.02.2006 -- hwyss@ywesee.com

require "state/global_predefine"
require "view/migel/alphabetical"

module ODDB
  module State
    module Migel
      class Alphabetical < Global
        include IndexedInterval
        VIEW = View::Migel::Alphabetical
        DIRECT_EVENT = :migel_alphabetical
        PERSISTENT_RANGE = true
        LIMITED = true
        def intervals
          @intervals or begin
            values = @session.app.migel_product_index_keys(@session.language)
            @intervals, @numbers = values.partition { |char|
              /[a-z]/ui.match(char)
            }
            unless @numbers.empty?
              @intervals.push("0-9")
            end
            @intervals
          end
        end

        def index_name
          lang = if @session.language == "en"
            "de"
          else
            @session.language
          end
          "migel_index_#{lang}"
        end

        def index_lookup(query)
          lang = if @session.language == "en"
            "de"
          else
            @session.language
          end
          @session.app.search_migel_alphabetical(query, lang)
        end
      end
    end
  end
end
