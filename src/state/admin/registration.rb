#!/usr/bin/env ruby

# ODDB::State::Admin::Registration -- oddb.org -- 17.07.2012 -- yasaka@ywesee.com
# ODDB::State::Admin::Registration -- oddb.org -- 16.01.2012 -- mhatakeyama@ywesee.com
# ODDB::State::Admin::Registration -- oddb.org -- 10.03.2003 -- hwyss@ywesee.com

require "plugin/text_info"
require "state/admin/global"
require "state/admin/sequence"
require "state/admin/selectindication"
require "state/admin/fachinfoconfirm"
require "state/admin/assign_fachinfo"
require "model/fachinfo"
require "view/admin/registration"
require "util/log"

module ODDB
  module State
    module Admin
      module FachinfoMethods
        FI_FILE_DIR = File.join(ODDB::RESOURCES_DIR, "fachinfo")
        def assign_fachinfo
          if @model.fachinfo
            State::Admin::AssignFachinfo.new(@session, @model)
          end
        end

        private

        def detect_type four_bytes
          if four_bytes[0..1] == "PK"
            [:docx, "application/application/vnd.openxmlformats-officedocument.wordprocessingml.document"]
          # disallow fi-pdf
          # elsif four_bytes == "%PDF"
          #  [:pdf, "application/pdf"]
          else
            [:doc, "application/msword"]
          end
        end

        def get_fachinfo
          new_state = self
          language = @session.user_input(:language_select)
          if language && (fi_file = @session.user_input(:fachinfo_upload))
            language = language.intern
            four_bytes = fi_file.read(4)
            fi_file.rewind
            mail_link = if reg = model.iksnr
              @session.lookandfeel.event_url(:drug, {"reg" => reg})
            else
              @session.lookandfeel.event_url(:resolve, {"pointer" => model.pointer})
            end
            type, mimetype = detect_type four_bytes
            filename = "#{@model.iksnr}_#{language}.#{type}"
            FileUtils.mkdir_p(self.class::FI_FILE_DIR)
            path = File.expand_path(filename, self.class::FI_FILE_DIR)
            File.open(path) do |fi_file|
              File.write(path, fi_file.read)
            end
            fi_file.rewind
            new_state = State::Admin::WaitForFachinfo.new(@session, @model)
            new_state.previous = self
            @session.app.async {
              @session.app.failsafe {
                if type == :doc or type == :docx
                  new_state.signal_done(parse_fachinfo(type, path),
                    path, @model, mimetype, language, mail_link)
                else
                  new_state.signal_done(parse_fachinfo(type, fi_file),
                    path, @model, mimetype, language, mail_link)
                end
              }
            }
          elsif @session.user_input(:textinfo_update)
            plugin = TextInfoPlugin.new @session.app, reparse: true
            plugin.import_fulltext @model.iksnr
            info = if plugin.updated_fis > 0 && plugin.updated_pis > 0
              :updated_textinfos
            elsif plugin.updated_fis > 0
              :updated_fachinfo
            elsif plugin.updated_pis > 0
              :updated_patinfo
            else
              :updated_textinfos_utd
            end
            @infos.push info
            log = Log.new Date.today
            log.update_values plugin.log_info
            log.notify "Fach- und Patienteninfo '#{@model.iksnr}'"
          end
          new_state
        end

        def parse_fachinfo(type, file)
          # establish connection to fachinfo_parser
          parser = DRbObject.new(nil, FIPARSE_URI)
          if type == :docx
            language = @session.user_input(:language_select)
            result = parser.send(:parse_fachinfo_docx, file, @model.iksnr, language.downcase)
          else
            result = parser.send("parse_fachinfo_#{type}", file.read)
          end
          result
        rescue ArgumentError
          msg = @session.lookandfeel.lookup(:e_not_a_wordfile)
          err = create_error(:e_fi_not_parsed, :fachinfo_upload, msg)
          @errors.store(:fachinfo_upload, err)
        rescue => e
          msg = " (" << e.message << ")"
          err = create_error(:e_fi_not_parsed, :fachinfo_upload, msg)
          @errors.store(:fachinfo_upload, err)
          e
        end
      end

      module RegistrationMethods
        include FachinfoMethods
        def do_update(keys)
          new_state = self
          hash = user_input(keys)
          if @model.is_a?(Persistence::CreateItem) && error?
            return new_state
          end
          resolve_company(hash)
          if hash[:registration_date].nil? && hash[:revision_date].nil?
            error = create_error("e_missing_reg_rev_date",
              :registration_date, nil)
            @errors.store(:registration_date, error)
            error = create_error("e_missing_reg_rev_date",
              :revision_date, nil)
            @errors.store(:revision_date, error)
          end
          ind = @session.user_input(:indication)
          sel = nil
          if (indication = @session.app.indication_by_text(ind))
            hash.store(:indication, indication.pointer)
          elsif !ind.empty?
            input = hash.dup
            input.store(:indication, ind)
            sel = SelectIndicationMethods::Selection.new(input,
              @session.app.search_indications(ind), @model)
            self.class::SELECT_STATE.new(@session, sel)
          end
          new_state = get_fachinfo
          @model = @session.app.update(@model.pointer, hash, unique_email)
          if sel
            sel.registration = @model
          end
          new_state
        end

        def new_patent
          model = if iksnr = @session.user_input(:reg)
            @session.app.registration(iksnr)
          end
          if model
            pointer = model.pointer
            pat_pointer = pointer + [:patent]
            item = Persistence::CreateItem.new(pat_pointer)
            item.carry(:iksnr, model.iksnr)
            if (klass = resolve_state(pat_pointer))
              klass.new(@session, item)
            else
              self
            end
          else
            self
          end
        end

        def new_sequence
          model = if @model.is_a?(ODDB::Registration)
            @model
          elsif iksnr = @session.persistent_user_input(:reg)
            @session.app.registration(iksnr)
          end
          if model
            pointer = model.pointer
            seq_pointer = pointer + [:sequence]
            item = Persistence::CreateItem.new(seq_pointer)
            item.carry(:iksnr, model.iksnr)
            item.carry(:company, model.company)
            item.carry(:compositions, [])
            item.carry(:packages, {})
            if (klass = resolve_state(seq_pointer))
              klass.new(@session, item)
            else
              self
            end
          else
            self
          end
        end

        def resolve_company(hash)
          comp_name = @session.user_input(:company_name)
          if (company = @session.company_by_name(comp_name) || @model.company)
            hash.store(:company, company.oid)
          else
            err = create_error(:e_unknown_company, :company_name, comp_name)
            @errors.store(:company_name, err)
          end
        end
      end

      class Registration < State::Admin::Global
        VIEW = View::Admin::RootRegistration
        SELECT_STATE = State::Admin::SelectIndication
        include RegistrationMethods
        def update
          keys = [
            :inactive_date, :generic_type, :registration_date,
            :revision_date, :market_date, :expiration_date,
            :complementary_type, :export_flag, :renewal_flag,
            :renewal_flag_swissmedic,
            :parallel_import, :index_therapeuticus, :ignore_patent,
            :ith_swissmedic, :activate_fachinfo, :deactivate_fachinfo, :manual_inactive_date,
            :vaccine, :keep_generic_type
          ]
          if @model.is_a? Persistence::CreateItem
            iksnr = @session.user_input(:iksnr)
            if error_check_and_store(:iksnr, iksnr, [:iksnr])
              return self
            elsif @session.app.registration(iksnr)
              error = create_error("e_duplicate_iksnr", :iksnr, iksnr)
              @errors.store(:iksnr, error)
              return self
            else
              @model.append(iksnr)
            end
          end
          do_update(keys)
        end
      end

      class CompanyRegistration < State::Admin::Registration
        def init
          super
          unless allowed?
            @default_view = ODDB::View::Admin::Registration
          end
        end

        def allowed?
          @session.allowed?("edit", @model.company)
        end

        def new_patent
          if allowed?
            super
          end
        end

        def new_sequence
          if allowed?
            super
          end
        end

        def resolve_company(hash)
          if @model.is_a?(Persistence::CreateItem)
            hash.store(:company, @session.user.model.oid)
          end
        end

        def update
          if allowed?
            super
          end
        end
      end

      class ResellerRegistration < Global
        include FachinfoMethods
        VIEW = View::Admin::ResellerRegistration
        def update
          company = @model.company
          if company.invoiceable?
            get_fachinfo
          else
            err = create_error(:e_company_not_invoiceable, :pdf_patinfo, nil)
            newstate = resolve_state(company.pointer).new(@session, company)
            newstate.errors.store(:pdf_patinfo, err)
            newstate
          end
        end
      end
    end
  end
end
