#!/usr/bin/env ruby

# ODDB::View::Doctors::Doctor -- oddb.org -- 15.08.2012 -- yasaka@ywesee.com
# ODDB::View::Doctors::Doctor -- oddb.org -- 31.10.2011 -- mhatakeyama@ywesee.com
# ODDB::View::Doctors::Doctor -- oddb.org -- 27.05.2003 -- usenguel@ywesee.com

require "htmlgrid/composite"
require "htmlgrid/labeltext"
require "htmlgrid/select"
require "htmlgrid/text"
require "htmlgrid/urllink"
require "htmlgrid/value"
require "htmlgrid/inputfile"
require "htmlgrid/errormessage"
require "htmlgrid/infomessage"
require "view/descriptionform"
require "view/form"
require "view/captcha"
require "view/address"
require "view/pointervalue"
require "view/privatetemplate"
require "view/sponsorlogo"

module ODDB
  module View
    module Doctors
      class Addresses < HtmlGrid::List
        COMPONENTS = {
          [0, 0]	=>	Address
        }
        CSS_MAP = {
          [0, 0]	=>	"top"
        }
        SORT_DEFAULT = nil
        OMIT_HEADER = true
        OFFSET_STEP = [1, 0]
        CSS_CLASS = "component"
        BACKGROUND_SUFFIX = " bg"
      end

      class ExperienceList < HtmlGrid::List
        COMPONENTS = {
          [0, 0] => :explanation,
          [0, 1] => :title,
          [0, 2] => :description
        }
        CSS_MAP = {
          [0, 0] => "list",
          [0, 1] => "list bold",
          [0, 2] => "list"
        }
        SORT_DEFAULT = nil
        OMIT_HEADER = true
        OFFSET_STEP = [0, 4]
        CSS_CLASS = "composite"
        BACKGROUND_SUFFIX = " bg"
        def explanation(model, session = @session)
          [
            @lookandfeel.lookup(:experience_of),
            model.doctor.fullname,
            @lookandfeel.lookup(:experience_posted),
            model.time.strftime(@lookandfeel.lookup(:time_format))
          ]
        end
      end

      class DoctorInnerComposite < HtmlGrid::Composite
        include VCardMethods
        COMPONENTS = {
          [0, 0] => :specialities_header,
          [0, 1] => :specialities,
          [0, 2] => :capabilities_header,
          [0, 3] => :capabilities,
          [0, 4, 0] => :language_header,
          [0, 4, 1] => :nbsp,
          [0, 4, 2] => :correspondence,
          [0, 5, 0] => :exam_header,
          [0, 5, 1] => :nbsp,
          [0, 5, 2] => :exam,
          [0, 6, 0] => :ean13_header,
          [0, 6, 1] => :nbsp,
          [0, 6, 2] => :ean13,
          [0, 7, 0] => :email_header_doctor,
          [0, 7, 1] => :nbsp,
          [0, 7, 2] => :email,
          [0, 8, 0] => :may_dispense_narcotics_header,
          [0, 8, 1] => :nbsp,
          [0, 8, 2] => :may_dispense_narcotics,
          [0, 9, 0] => :may_sell_drugs_header,
          [0, 9, 1] => :nbsp,
          [0, 9, 2] => :may_sell_drugs,
          [0, 9, 3] => :nbsp,
          [0, 9, 4] => :remark_sell_drugs,
          [0, 10] => :addresses,
          [0, 11] => :vcard
        }
        SYMBOL_MAP = {
          address_email: HtmlGrid::MailLink,
          capabilities_header: HtmlGrid::LabelText,
          email: HtmlGrid::MailLink,
          email_header_doctor: HtmlGrid::LabelText,
          exam_header: HtmlGrid::LabelText,
          ean13_header: HtmlGrid::LabelText,
          language_header: HtmlGrid::LabelText,
          nbsp: HtmlGrid::Text,
          phone_label: HtmlGrid::Text,
          fax_label: HtmlGrid::Text,
          specialities_header: HtmlGrid::LabelText,
          may_sell_drugs_header: HtmlGrid::LabelText,
          may_dispense_narcotics_header: HtmlGrid::LabelText,
          url: HtmlGrid::HttpLink,
          url_header: HtmlGrid::LabelText,
          work_header: HtmlGrid::LabelText
        }
        CSS_MAP = {
          [0, 0, 4, 8] => "list",
          [0, 8] => "list",
          [0, 9] => "list"
        }
        DEFAULT_CLASS = HtmlGrid::Value
        LEGACY_INTERFACE = false
        def flatten_cap(list)
          result = []
          list.each { |item| result << item.gsub(/(\["|"\])/, "") if item }
          result.join("<br>")
        end

        def specialities(model)
          spc = model.specialities
          flatten_cap(spc) unless spc.nil?
        end

        def capabilities(model)
          spc = model.capabilities
          flatten_cap(spc) unless spc.nil?
        end

        def may_sell_drugs(model)
          if model.may_sell_drugs
            @lookandfeel.lookup(:true)
          else
            @lookandfeel.lookup(:false)
          end
        end

        def may_sell_drugs(model)
          if model.may_sell_drugs
            @lookandfeel.lookup(:true)
          else
            @lookandfeel.lookup(:false)
          end
        end

        def may_dispense_narcotics(model)
          if model.may_dispense_narcotics
            @lookandfeel.lookup(:true)
          else
            @lookandfeel.lookup(:false)
          end
        end

        def addresses(model)
          addrs = model.addresses
          if addrs.empty?
            addrs = addrs.dup
            addr = ODDB::Address2.new
            addr.pointer = model.pointer + [:address, 0] if model.pointer
            addrs.push(addr)
          end
          Addresses.new(addrs, @session, self)
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

      class DoctorForm < View::Form
        include HtmlGrid::ErrorMessage
        COMPONENTS = {
          [0, 0] => :title,
          [0, 1] => :name_first,
          [2, 1] => :name,
          [0, 2] => :specialities,
          [0, 3] => :capabilities,
          [0, 4] => :correspondence,
          [0, 5] => :exam,
          [0, 6] => :ean13,
          [0, 7] => :email,
          [1, 8] => :submit
        }
        COLSPAN_MAP = {
          [1, 2] => 3,
          [1, 3] => 3
        }
        COMPONENT_CSS_MAP = {
          [0, 0] => "standard",
          [0, 1] => "standard",
          [2, 1] => "standard",
          # [0,2] => 'standard',
          # [0,3] => 'standard',
          [0, 4] => "standard",
          [0, 5] => "standard",
          [0, 6] => "standard",
          [0, 7] => "standard"
        }
        CSS_MAP = {
          [0, 0, 4, 8] => "list",
          [0, 2, 1, 2] => "list top"
        }
        LABELS = true
        LEGACY_INTERFACE = false
        def init
          super
          error_message
        end

        def capabilities(model)
          input = HtmlGrid::Textarea.new(:capabilities, model, @session, self)
          input.label = true
          input
        end

        def specialities(model)
          input = HtmlGrid::Textarea.new(:specialities, model, @session, self)
          input.label = true
          input
        end
      end

      class DoctorExperienceForm < View::Form
        include HtmlGrid::ErrorMessage
        include Captcha
        COMPONENTS = {
          [0, 0] => "experience_explain",
          [0, 1] => :title,
          [0, 2] => :description,
          [0, 3] => "experience_notes",
          [0, 4] => :captcha,
          [0, 6] => :experiences
        }
        COLSPAN_MAP = {
          [0, 0] => 3,
          [0, 1] => 3,
          [0, 2] => 3,
          [0, 3] => 3,
          [0, 6] => 3
        }
        CSS_MAP = {
          [0, 0] => "list bold",
          [0, 1] => "list",
          [0, 2] => "list",
          [0, 3] => "list",
          [0, 4] => "list",
          [0, 6] => "experience top border-top"
        }
        LABELS = false
        EVENT = :update_experience
        def init
          super
          error_message
        end

        def title(model, session)
          input = HtmlGrid::InputText.new(:title, model, session, self)
          title_text = session.lookandfeel.lookup(:experience_title)
          input.set_attribute("onFocus", "if (this.value == '#{title_text}') { value = '' };")
          input.set_attribute("onBlur", "if (this.value == '') { value = '#{title_text}' };")
          input.set_attribute("size", "45")
          input.value = title_text
          if previous_text = @session.user_input(:title)
            input.value = previous_text
          end
          input
        end

        def description(model, session)
          textarea = HtmlGrid::Textarea.new(:description, model, session, self)
          textarea_text = session.lookandfeel.lookup(:experience_text)
          textarea.set_attribute("onFocus", "if (this.value == '#{textarea_text}') { value = '' };")
          textarea.set_attribute("onBlur", "if (this.value == '') { value = '#{textarea_text}' };")
          textarea.set_attribute("class", "big")
          textarea.value = textarea_text
          if previous_text = @session.user_input(:description)
            textarea.value = previous_text
          end
          textarea
        end

        def captcha(model, session)
          input = super(model)
          captcha_text = session.lookandfeel.lookup(:captcha)
          input.set_attribute("onFocus", "if (this.value == '#{captcha_text}') { value = '' };")
          input.set_attribute("onBlur", "if (this.value == '') { value = '#{captcha_text}' };")
          input.set_attribute("size", "30")
          input.value = captcha_text
          button = submit(model, session)
          button.set_attribute("value", session.lookandfeel.lookup(:update))
          [input, "&nbsp;", button]
        end

        def experiences(model, session = @session)
          experiences = []
          if model.experiences and !model.experiences.empty?
            experiences = model.experiences.select { |exp| !exp.hidden }
          end
          View::Doctors::ExperienceList.new(experiences, session, self)
        end
      end

      class DoctorComposite < HtmlGrid::Composite
        COMPONENTS = {
          [0, 0, 0] => :title,
          [0, 0, 1] => :nbsp,
          [0, 0, 2] => :firstname,
          [0, 0, 3] => :nbsp,
          [0, 0, 4] => :name,
          [1, 0] => "experience_header",
          [0, 1] => DoctorInnerComposite,
          [1, 1] => DoctorExperienceForm
        }
        SYMBOL_MAP = {
          nbsp: HtmlGrid::Text
        }
        CSS_MAP = {
          [0, 0] => "th",
          [1, 0] => "th",
          [0, 1] => "top",
          [0, 2] => "top",
          [0, 3] => "list",
          [1, 1] => "experience top",
          [1, 2] => "experience top border-top"
        }
        COLSPAN_MAP = {}
        CSS_CLASS = "composite"
        DEFAULT_CLASS = HtmlGrid::Value
        LEGACY_INTERFACE = false
      end

      class RootDoctorComposite < DoctorComposite
        COMPONENTS = {
          [0, 0, 0] => :title,
          [0, 0, 1] => :nbsp,
          [0, 0, 2] => :firstname,
          [0, 0, 3] => :nbsp,
          [0, 0, 4] => :name,
          [0, 1] => DoctorForm,
          [0, 2] => :addresses,
          [0, 3] => :vcard
        }
        CSS_MAP = {
          [0, 0] => "th"
        }
      end

      class Doctor < PrivateTemplate
        CONTENT = View::Doctors::DoctorComposite
        SNAPBACK_EVENT = :result
      end

      class RootDoctor < PrivateTemplate
        CONTENT = RootDoctorComposite
        SNAPBACK_EVENT = :result
      end
    end
  end
end
