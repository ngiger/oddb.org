#!/usr/bin/env ruby

# ODDB::State::Interactions::Interactions -- oddb.org -- 21.02.2012 -- mhatakeyama@ywesee.com

require	"state/global_predefine"
require	"view/interactions/interactions"
require "rexml/document"
require "net/https"
require "view/pointervalue"

module ODDB
  module State
    module Interactions
      class Interactions < State::Interactions::Global
        VIEW = View::Interactions::Interactions
        DIRECT_EVENT = :interactions
        LIMITED = false
        def init
          @model = []
          if atc_codes = @session.interaction_basket_atc_codes and !atc_codes.empty? \
            and substances = @session.interaction_basket and !substances.empty?

            # get xml document
            server_url = "api.epha.ch"
            interaction_key = if ODDB.config.respond_to?(:interaction_key)
              ODDB.config.interaction_key
            else
              "79VVZ51XJKSEN1G"
            end
            base_url = "/1.0/interaction/list?atc=#{atc_codes.join(",")}&key=#{interaction_key}"
            https = Net::HTTP.new(server_url, 443)
            https.use_ssl = true
            https.ssl_version = :SSLv3
            https.verify_mode = OpenSSL::SSL::VERIFY_NONE

            xml = ""
            https.start { |w|
              response = w.get(base_url)
              xml = response.body
            }

            # parse xml document
            doc = REXML::Document.new(xml)
            if interactions = doc.elements["/EPha/Response/Interactions"]
              interactions.each do |element|
                active_sub_id = atc_codes.index(element.attributes["active"])
                passive_sub_id = atc_codes.index(element.attributes["passive"])
                @model << {
                  substance_active: substances[active_sub_id].name,
                  substance_passive: substances[passive_sub_id].name,
                  active: element.attributes["active"],
                  passive: element.attributes["passive"],
                  info: element.attributes["info"],
                  rating: element.attributes["rating"]
                }
              end
            end
          end
        end
      end
    end
  end
end
