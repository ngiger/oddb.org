#!/usr/bin/env ruby

# View::User::RegisterDownload -- oddb -- 20.09.2004 -- mhuggler@ywesee.com

require "htmlgrid/errormessage"
require "htmlgrid/select"
require "view/paypal/invoice"
require "view/publictemplate"
require "view/form"
require "view/user/autofill"

module ODDB
  module View
    module User
      class RegisterDownloadForm < Form
        include AutoFill
        include HtmlGrid::ErrorMessage
        COMPONENTS = {
          [0, 0]	=>	:email,
          [0, 1]	=>	:salutation,
          [0, 2]	=>	:name_last,
          [0, 3]	=>	:name_first,
          [0, 4]	=>	:company_name,
          [0, 5]	=>	:address,
          [0, 6]	=>	:plz,
          [0, 7]	=>	:city,
          [0, 8]	=>	:phone,
          [0, 9] =>	:business_area,
          [1, 10] =>	:submit
        }
        CSS_CLASS = "component"
        HTML_ATTRIBUTES = {
          "style"	=>	"width:30%"
        }
        EVENT = :checkout
        LABELS = true
        CSS_MAP = {
          [0, 0, 4, 11]	=>	"list"
        }
        COMPONENT_CSS_MAP = {
          [1, 0, 3, 10]	=>	"standard"
        }
        SYMBOL_MAP = {
          salutation: HtmlGrid::Select,
          business_area: HtmlGrid::Select,
          pass: HtmlGrid::Pass,
          set_pass_2: HtmlGrid::Pass
        }
        LEGACY_INTERFACE = false
        def init
          unless @session.logged_in?
            hash_insert_row(components, [0, 1], :pass)
            components.store([3, 1], :set_pass_2)
            css_map.store([0, 11, 4], "list")
            component_css_map.store([1, 10], "standard")
          end
          super
          if @session.error?
            error = RuntimeError.new("e_need_all_input")
            __message(error, "processingerror")
          end
        end

        def hidden_fields(context)
          hidden = super
          if (downloads = @session.user_input(:download))
            downloads.each { |key, val|
              hidden << context.hidden("download[#{key}]", val)
            }
          end
          if (months = @session.user_input(:months))
            months.each { |key, val|
              hidden << context.hidden("months[#{key}]", val)
            }
          end
          hidden
        end
      end

      class RegisterDownloadComposite < HtmlGrid::Composite
        include View::PayPal::InvoiceMethods
        COMPONENTS = {
          [0, 0]	=>	SelectSearchForm,
          [0, 1, 0]	=>	"register_download",
          [0, 1, 1]	=>	"dash_separator",
          [0, 2]	=>	"register_download_descr",
          [0, 3]	=>	:register_download_form,
          [1, 3]	=>	:invoice_items
        }
        CSS_CLASS = "composite"
        CSS_MAP = {
          [0, 0] => "right",
          [0, 2]	=>	"list"
        }
        COLSPAN_MAP = {
          [0, 0] => 2,
          [0, 1] => 2,
          [0, 2] => 2
        }
        LEGACY_INTERFACE = false
        def register_download_form(model)
          if @session.logged_in?
            model = @session.user
          end
          RegisterDownloadForm.new(model, @session, self)
        end
      end

      class RegisterDownload < View::PublicTemplate
        JAVASCRIPTS = ["autofill"]
        CONTENT = RegisterDownloadComposite
      end
    end
  end
end
