#!/usr/bin/env ruby

# ODDB::Validator -- oddb.org -- 29.10.2012 -- yasaka@ywesee.com
# ODDB::Validator -- oddb.org -- 14.02.2012 -- mhatakeyama@ywesee.com
# ODDB::Validator -- oddb.org -- 18.11.2002 -- hwyss@ywesee.com

require "sbsm/validator"
require "model/ba_type"
require "model/ean13"
require "cgi"
require "mail"

module ODDB
  class Validator < SBSM::Validator
    alias_method :partner, :flavor
    alias_method :set_pass_2, :pass
    alias_method :invoice_email, :email
    alias_method :unique_email, :email
    alias_method :notify_sender, :email
    alias_method :receiver_email, :email
    alias_method :competition_email, :email
    alias_method :swissmedic_email, :email
    BOOLEAN = [
      :cl_status, :deductible_display, :disable, :disable_ddd_price,
      :disable_invoice_fachinfo, :disable_invoice_patinfo,
      :disable_patinfo, :disable_photo_forwarding, :download, :experience, :export_flag, :helps,
      :ignore_patent, :impression, :invoice_htmlinfos, :limit_invoice_duration, :lppv,
      :parallel_import, :preview_with_market_date, :recommend,
      :refdata_override, :remember_me, :renewal_flag,
      :search_limitation_A, :search_limitation_B,
      :search_limitation_C, :search_limitation_D, :search_limitation_E,
      :search_limitation_SL_only, :search_limitation_valid,
      :show_email, :vaccine, :yus_groups, :yus_privileges,
      :textinfo_update, :keep_generic_type
    ]
    DATES = [
      :activate_fachinfo,
      :activate_patinfo,
      :base_patent_date,
      :deactivate_fachinfo,
      :deactivate_patinfo,
      :deletion_date,
      :expiration_date,
      :expiry_date,
      :inactive_date,
      :introduction_date,
      :invoice_date_fachinfo,
      :invoice_date_index,
      :invoice_date_lookandfeel,
      :invoice_date_patinfo,
      :issue_date,
      :market_date,
      :manual_inactive_date,
      :patented_until,
      :protection_date,
      :publication_date,
      :registration_date,
      :revision_date,
      :sequence_date,
      :sponsor_until,
      :valid_until
    ]
    ENUMS = {
      atc_origins: [nil, :whocc, :swissmedic, :refdata],
      address_type: [nil, "at_work", "at_praxis",
        "at_private"],
      business_area: ODDB::BA_types,
      canton: [nil, "AG", "AI", "AR", "BE",
        "BL", "BS", "FR", "GE", "GL", "GR", "JU", "LU",
        "NE", "NW", "OW", "SG", "SH", "SO", "SZ", "TG",
        "TI", "UR", "VD", "VS", "ZG", "ZH"],
      channel: [
        "fachinfo.rss", "feedback.rss", "minifi.rss",
        "price_cut.rss", "price_rise.rss", "sl_introduction.rss",
        "recall.rss", "hpc.rss"
      ],
      cl_status: ["false", "true"],
      complementary_type: [nil, "anthroposophy", "homeopathy", "phytotherapy"],
      compression: ["compr_zip", "compr_gz"],
      deductible: [nil, "deductible_g", "deductible_o"],
      deductible_m: [nil, "deductible_g", "deductible_o"],
      search_type: [
        "st_oddb", "st_combined", "st_sequence", "st_substance",
        "st_company", "st_indication", "st_interaction",
        "st_unwanted_effect", "st_registration", "st_pharmacode"
      ],
      fi_status: ["false", "true"],
      generic_type: [nil, "generic", "original"],
      sl_generic_type: [nil, "generic", "original"],
      limitation: ["true", "false"],
      payment_method: ["pm_invoice", "pm_paypal"],
      patinfo: ["delete", "keep"],
      resultview: ["atc", "pages"],
      route_of_administration: [nil, "roa_O", "roa_P", "roa_N", "roa_SL",
        "roa_TD", "roa_R", "roa_V"],
      salutation: ["salutation_m", "salutation_f"],
      search_form: ["plus", "instant", "normal"],
      style: ["default", "blue", "red", "olive", "purple"],
      yus_privileges: [
        "edit|yus.entities",
        "grant|login",
        "grant|view",
        "grant|create",
        "grant|edit",
        "grant|credit",
        "set_password",
        "login|org.oddb.RootUser",
        "login|org.oddb.AdminUser",
        "login|org.oddb.PowerUser",
        "login|org.oddb.CompanyUser",
        "login|org.oddb.PowerLinkUser",
        # 'view|org.oddb',
        "edit|org.oddb.drugs",
        "edit|org.oddb.powerlinks",
        "create|org.oddb.registration",
        "create|org.oddb.task.background",
        "edit|org.oddb.model.!company.*",
        "edit|org.oddb.model.!sponsor.*",
        "edit|org.oddb.model.!indication.*",
        "edit|org.oddb.model.!galenic_group.*",
        "edit|org.oddb.model.!address.*",
        "edit|org.oddb.model.!atc_class.*",
        "invoice|org.oddb.processing",
        "view|org.oddb.patinfo_stats",
        "view|org.oddb.patinfo_stats.associated",
        "credit|org.oddb.download"
      ]
    }
    EVENTS = [
      :accept,
      :add_to_interaction_basket,
      :addresses,
      :address_suggestion,
      :ajax,
      :ajax_autofill,
      :ajax_add_drug,
      :ajax_add_fi,
      :ajax_create_active_agent,
      :ajax_create_composition,
      :ajax_create_fachinfo_link,
      :ajax_create_part,
      :ajax_delete_active_agent,
      :ajax_delete_composition,
      :ajax_delete_fachinfo_link,
      :ajax_delete_part,
      :ajax_delete_drug,
      :ajax_ddd_price,
      :ajax_matches,
      :ajax_swissmedic_cat,
      :api_search,
      :assign,
      :assign_deprived_sequence,
      :assign_division,
      :assign_fachinfo,
      :assign_patinfo,
      :atc_class,
      :atc_chooser,
      :atc_request,
      # :authenticate,
      :address_send,
      :back,
      :calculate_offer,
      :diff,
      :checkout,
      :choice,
      :clear_interaction_basket,
      :commercial_form,
      :commercial_forms,
      :company,
      :companylist,
      :compare,
      :compare_search,
      :data, # download_item
      :ddd,
      :ddd_chart,
      :ddd_price,
      :delete,
      :delete_all,
      :delete_connection_key,
      :delete_orphaned_fachinfo,
      :delete_orphaned_patinfo,
      :doctor,
      :doctorlist,
      :download,
      :download_credit,
      :download_export,
      :drug,
      :effective_substances,
      :export_csv,
      :fachinfo,
      :fachinfos,
      :feedbacks,
      :foto, # photo
      :galenic_form,
      :galenic_group,
      :galenic_groups,
      :help,
      :home,
      :home_admin,
      :home_companies,
      :home_doctors,
      :home_drugs,
      :home_pharmacies,
      :home_hospitals,
      :home_interactions,
      :home_migel,
      :home_substances,
      :home_user,
      :pharmacy,
      :hospital,
      :hospitallist,
      :indication,
      :indications,
      :interaction_basket,
      :interaction_chooser,
      :interaction_detail,
      :interactions,
      :legal_note,
      :limitation_text,
      :limitation_texts,
      :listed_companies,
      :login,
      :login_form,
      :logout,
      :merge,
      :migel_alphabetical,
      :migel_search,
      :minifi,
      :narcotic,
      :narcotics,
      :narcotic_plus,
      :new_active_agent,
      :new_commercial_form,
      :new_company,
      :new_fachinfo,
      :new_galenic_form,
      :new_galenic_group,
      :new_indication,
      :new_item,
      :new_package,
      :new_patent,
      :new_registration,
      :new_sequence,
      :new_substance,
      :new_user,
      :notify_send,
      :orphaned_fachinfos,
      :orphaned_patinfos,
      :passthru,
      :password_lost,
      :password_request,
      :password_reset,
      :patinfo_deprived_sequences,
      :patinfo,
      :patinfos,
      :patinfo_stats,
      :patinfo_stats_company,
      :paypal_ipn,
      :paypal_return,
      :paypal_thanks,
      :pharmacylist,
      :powerlink,
      :preview,
      :price_history,
      :print,
      :proceed_download,
      :proceed_payment,
      :proceed_poweruser,
      :recent_registrations,
      :resolve,
      :result,
      :rss,
      :search,
      :search_registrations,
      :search_sequences,
      :select_seq,
      :sequences,
      :set_pass,
      :shadow,
      :shadow_pattern,
      :shorten_path,
      :show,
      :sl_entry,
      :sort,
      :sponsor,
      :sponsorlink,
      :preferences,
      :substance,
      :substances,
      :suggest_address,
      :suggest_choose,
      :switch,
      :update,
      :update_bsv,
      :update_experience,
      :user,
      :users,
      :vaccines,
      :vcard,
      :wait,
      :ywesee_contact
    ]
    FILES = [
      :logo_file,
      :logo_fr,
      :fachinfo_upload,
      :html_upload,
      :patinfo_upload
    ]
    HTML = [:html_chapter]
    NUMERIC = [
      :active_agent,
      :change_flags,
      :composition,
      :count,
      :days,
      :exam,
      :fachinfo_price,
      :fachinfo_index,
      :factor,
      :fi_quantity,
      :index,
      :invoice,
      :item_number,
      :limitation_points,
      :longevity,
      :lookandfeel_member_count,
      :meaning_index,
      :month,
      :months,
      :multi,
      :part,
      :price_fachinfo,
      :price_index,
      :price_index_package,
      :price_lookandfeel,
      :price_lookandfeel_member,
      :price_patinfo,
      :pi_quantity,
      :pharmacode,
      :price_exfactory,
      :price_public,
      :year
    ]
    STRINGS = [
      :additional_lines,
      :address,
      :address_email,
      :atc_descr,
      :atc_code,
      :bsv_url,
      :business_unit,
      :capabilities,
      :captcha,
      :certificate_number,
      :challenge,
      :diff,
      :chapter,
      :chemical_substance,
      :city,
      :commercial_form,
      :company,
      :company_form,
      :company_name,
      :comparable_size,
      :composition_text,
      :connection_key,
      :contact,
      :contact_email,
      :correspondence,
      :de,
      :descr,
      :description,
      :destination,
      :doctor,
      :division_divisable,
      :division_dissolvable,
      :division_crushable,
      :division_openable,
      :division_notes,
      :division_source,
      :effective_form,
      :en,
      :equivalent_substance,
      :experience,
      :fax,
      :buy, # file
      :fi_update,
      :fi_link_name,
      :fi_link_url,
      :fi_link_created,
      :fi_path_shorten_path,
      :fi_path_origin_path,
      :fi_path_created,
      :fachinfo,
      :fon,
      :for,
      :fr,
      :foid,
      :goid,
      :galenic_form,
      :generic_group,
      :group,
      :heading,
      :highlight,
      :pharmacy,
      :hospital,
      :index_name,
      :index_therapeuticus,
      :indication,
      :ith_swissmedic,
      :language_select,
      :location,
      :lt,
      :message,
      :migel_code,
      :migel_limitation,
      :migel_group,
      :migel_product,
      :migel_subgroup,
      :name,
      :name_base,
      :name_descr,
      :name_first,
      :name_last,
      :notify_message,
      :oid,
      :pattern,
      :payment_status,
      :phone, ## needed for download-registration!!
      :photo_link,
      :pi_update,
      :plz,
      :pointer_list,
      :powerlink,
      :position,
      :range,
      :register_update,
      :regulatory_email,
      :remember,
      :reverse,
      :size,
      :sortvalue,
      :specialities,
      :subscribe,
      :substance,
      :substance_form,
      :substance_ids,
      :swissmedic_salutation,
      :synonym_list,
      :targets,
      :title,
      :token,
      :txn_id,
      :unsubscribe,
      :url,
      :urls
    ]
    ZONES = [:admin, :pharmacies, :doctors, :interactions, :drugs, :migel, :user,
      :hospitals, :substances, :companies]
    def code(value)
      pattern = /^[A-Z]([0-9]{2}([A-Z]([A-Z]([0-9]{2})?)?)?)?$/iu
      if (valid = pattern.match(value.capitalize))
        valid[0].upcase
      elsif value.empty?
        nil
      else
        raise SBSM::InvalidDataError.new(:e_invalid_atc_class, :atc_class, value)
      end
    end
    @@dose = /(\d+(?:[.,]\d+)?)\s*(.*)/u
    def dose(value)
      return nil if value.empty?
      value.force_encoding("utf-8")
      if (valid = @@dose.match(value))
        qty = valid[1].tr(",", ".")
        [qty.to_f, valid[2].to_s]
      else
        raise SBSM::InvalidDataError.new(:e_invalid_dose, :dose, value)
      end
    end
    alias_method :pretty_dose, :dose
    alias_method :chemical_dose, :dose
    alias_method :equivalent_dose, :dose
    alias_method :measure, :dose
    alias_method :ddd_dose, :dose
    def filename(value)
      if value == File.basename(value)
        value
      end
    end

    def ean13(value)
      return "" if value.empty?
      ODDB::Ean13.new(value)
    end
    alias_method :ean, :ean13
    def emails(value)
      return if value.empty?
      parsed = Mail::Address.new(value.to_s)
      return [parsed.to_s] if parsed.to_s and parsed.domain
      if parsed.nil?
        raise SBSM::InvalidDataError.new(:e_invalid_email_address, :email, value)
      else
        raise SBSM::InvalidDataError.new(:e_domainless_email_address, :email, value)
      end
    end

    def email_suggestion(value)
      unless value.empty?
        email(value)
      end
    end

    def galenic_group(value)
      pointer(value)
    end
    @@ikscat = /[ABCDE]|Sp/u
    def ikscat(value)
      return "" if value.empty?
      if (valid = @@ikscat.match(value.capitalize))
        valid[0]
      else
        raise SBSM::InvalidDataError.new(:e_invalid_ikscat, :ikscat, value)
      end
    end

    def ikscd(value)
      swissmedic_id(:ikscd, value, 1..3, 3)
    end
    alias_method :pack, :ikscd
    def iksnr(value)
      swissmedic_id(:iksnr, value, 4..7)
    rescue SBSM::InvalidDataError
      return value if value.length == 10
      raise SBSM::InvalidDataError.new("e_invalid_iksnr", :iksnr, value)
    end
    alias_method :reg, :iksnr
    def notify_recipient(value)
      [Mail::Address.new(value.to_s).to_s]
    end

    def search_query(value)
      result = validate_string(value).gsub(/\*/u, "")

      if result.length > 2
        result
      else
        raise SBSM::InvalidDataError.new(:e_search_query_short, :search_query, value)
      end
    end

    def set_pass_1(value)
      if value.to_s.size < 4
        raise SBSM::InvalidDataError.new("e_missing_password",
          :set_pass_1, value)
      end
      pass(value)
    end

    def seqnr(value)
      swissmedic_id(:seqnr, value, 1..2, 2)
    end
    alias_method :seq, :seqnr
    @@swissmedic = /^\d+$/u
    def swissmedic_id(key, value, range, pad = false)
      return value if value.empty?
      value.force_encoding("utf-8")
      valid = @@swissmedic.match(value)
      if valid && range.include?(valid[0].length)
        if pad
          sprintf("%0#{pad}d", valid[0].to_i)
        else
          valid[0]
        end
      else
        raise SBSM::InvalidDataError.new("e_invalid_#{key}", key, value)
      end
    end

    def page(value)
      validate_numeric(:page, value).to_i - 1
    end

    def pointer(value)
      raise SBSM::InvalidDataError.new("e_invalid_pointer", :pointer, value)
    end
    @@yus = /^org\.oddb\.model\.[!*.a-z]+/u
    def yus_association(value)
      value = value.to_s
      if @@yus.match(value.to_s)
        value
      elsif !value.empty?
        raise SBSM::InvalidDataError.new("e_invalid_yus_association",
          :yus_association, value)
      end
    end

    def zone(value)
      if value.to_s.empty?
        raise SBSM::InvalidDataError.new("e_invalid_zone", :zone, value)
      end
      zone = value.to_sym
      if self.class::ZONES.include?(zone)
        zone
      else
        raise SBSM::InvalidDataError.new("e_invalid_zone", :zone, value)
      end
    end
    alias_method :pointers, :pointer
    alias_method :patinfo_pointer, :pointer
  end
end
