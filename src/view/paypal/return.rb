#!/usr/bin/env ruby

# View::PayPal::Return -- ODDB -- 21.04.2005 -- hwyss@ywesee.com

require "view/resulttemplate"

module ODDB
  module View
    module PayPal
      class ReturnDownloads < HtmlGrid::List
        COMPONENTS = {
          [0, 0]	=>	:download_link,
          [1, 0]	=>	:additional_download_link
        }
        CSS_MAP = {}
        DEFAULT_HEAD_CLASS = "subheading"
        LEGACY_INTERFACE = false
        OMIT_HEADER = false
        STRIPED_BG = false
        SORT_HEADER = false
        def additional_download_link(model)
          protocol = DOWNLOAD_PROTOCOLS.find { |prt| %r{#{prt}}.match(model.text) }
          if protocol && !model.expired?
            data = {
              email: model.email,
              invoice: model.oid,
              filename: model.text
            }
            link = HtmlGrid::Link.new(:download, model, @session, self)
            url = URI.parse @lookandfeel._event_url(:download, data)
            url.scheme = protocol
            link.href = url.to_s
            link.value = protocol + "://" + model.text
            [link, " ", @lookandfeel.lookup("adl_#{protocol}")]
          end
        end

        def download_link(model)
          if model.expired?
            time = model.expiry_time
            timestr = time \
              ? time.strftime(@lookandfeel.lookup(:time_format_long))
              : @lookandfeel.lookup(:paypal_e_invalid_time)
            @lookandfeel.lookup(:paypal_e_expired, model.text, timestr)
          else
            data = {
              email: model.email,
              invoice: model.oid,
              filename: model.text
            }
            link = HtmlGrid::Link.new(:download, model, @session, self)
            link.href = @lookandfeel._event_url(:download, data)
            link.value = "http://" << model.text
            link
          end
        end
      end

      class ReturnComposite < HtmlGrid::Composite
        ## in this class, COMPONENTS only includes the unchanging components
        COMPONENTS = {
          [0, 0, 1]	=>	"dash_separator"
        }
        CSS_CLASS = "composite"
        CSS_MAP = {
          [0, 0]	=>	"th",
          [0, 1]	=>	"list"
        }
        LEGACY_INTERFACE = false
        def init
          if @model.nil?
            components.update({
              [0, 0, 0]	=>	"paypal_unconfirmed",
              [0, 1]	=>	"paypal_e_missing_invoice",
              [0, 2]	=>	:back
            })
            css_map.store([0, 1], "error")
          elsif @model.payment_received?
            suffix = (@model.items.size == 1) ? "s" : "p"
            txt = @model.items.first.text
            if DOWNLOAD_PROTOCOLS.find { |prt| %r{#{prt}}.match(txt) }
              suffix = "p"
            end
            if @model.items.first.type.to_s == "poweruser"
              components.update({
                [0, 1] => @lookandfeel.lookup(:paypal_msg_success_power) + @model.items.first.expiry_time.strftime("%Y.%m.%d %H:%M"),
                [0, 2] => :forward_to_home
              })
            else
              components.update({
                [0, 0, 0]	=>	"paypal_success",
                [0, 1] =>	"paypal_msg_success_#{suffix}",
                [0, 2] =>	:download_links,
                [0, 3] =>	:back
              })
            end
          else
            components.update({
              [0, 0, 0]	=>	"paypal_unconfirmed",
              [0, 1]	=>	"paypal_msg_unconfirmed",
              [0, 2]	=>	:back
            })
          end
          super
        end

        def forward_to_home(model)
          link_home = HtmlGrid::Link.new(:forward_to_home, model, @session, self)
          link_home.href = @lookandfeel._event_url(:home)
          link_home
        end

        def back(model)
          button = super
          button.value = @lookandfeel.lookup(:back_to_download)
          button
        end

        def download_links(model)
          ReturnDownloads.new(model.items, @session, self)
        end
      end

      class Return < PublicTemplate
        CONTENT = ReturnComposite
        def http_headers
          headers = super
          if @model && !@model.payment_received?
            args = {invoice: @model.oid}
            ## use event_url as opposed to _event_url in order to include
            ## the state-id, so we stay in the same state instead of
            ## creating a new one with each refresh
            url = @lookandfeel.event_url(:paypal_return, args)
            headers.store("Refresh", "10; URL=#{url}")
          end
          headers
        end
      end
    end
  end
end
