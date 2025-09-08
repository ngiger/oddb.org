#!/usr/bin/env ruby

require "plugin/yaml"
require "plugin/csv_export"
require "plugin/patinfo_invoicer"
require "plugin/fachinfo_invoicer"
require "plugin/ouwerkerk"
require "plugin/xls_export"
require "plugin/swissmedic"
require "util/log"
require "util/logfile"
require "util/schedule"
require "util/mail"
require "util/workdir"

module ODDB
  class Exporter
    include Util::Schedule
    EXPORT_SERVER = DRbObject.new(nil, EXPORT_URI)
    FileUtils.mkdir_p(EXPORT_DIR)
    class SessionStub
      attr_accessor :language, :flavor, :lookandfeel
      alias_method :default_language, :language
    end

    private

    def logExport(msg)
      return if defined?(Minitest)
      now = Time.now
      $stdout.puts("#{now}: #{msg}")
      $stdout.flush
      LogFile.append("oddb/debug", " " + msg, now)
      system("logger #{__FILE__}: #{msg}")
    end

    def restart_export_server(sleep_time = 60)
      logExport("restart_export_server. Called from #{caller(1..1).first.split(":in ")[0]}")
      EXPORT_SERVER.clear
      sleep(sleep_time)
      logExport("restart_export_server. Done sleeping #{sleep_time} seconds")
      sleep 0.1 # to be compatible with return code of old sleep
    end

    public

    # options parameter is needed to be compatible with calls via update_notify_simple
    def initialize(app, options = nil)
      @app = app
    end

    def run
      #
      # As decided by Zeno on August 14 2017, we do not need these invoices anymore
      # mail_patinfo_invoices
      # mail_fachinfo_log
      run_on_monthday(1) {
        mail_download_invoices
      }
      run_on_monthday(15) {
        mail_download_invoices
      }
      run_on_weekday(0) {
        mail_download_stats
        mail_feedback_stats
        export_yaml
        export_galenic
      }
      export_sl_pcodes
      # export_yaml
      export_csv
      export_doc_csv
      export_index_therapeuticus_csv
      export_price_history_csv
      # # inoperable atm.
      #       run_on_monthday(1) {
      #         export_fachinfo_pdf
      #       }
      restart_export_server
      nil
    end

    def export_helper(name)
      EXPORT_SERVER.remote_safe_export(EXPORT_DIR, name) { |path|
        yield path
      }
    end

    def export_all_csv
      export_csv
      export_doc_csv
      export_index_therapeuticus_csv
      export_price_history_csv
    end

    def export_competition_xls(company, db_path = nil)
      plug = XlsExportPlugin.new(@app)
      plug.export_competition(company, db_path)
      plug
    end

    def export_ddd_csv
      plug = CsvExportPlugin.new(@app)
      safe_export "ddd.csv" do
        plug.export_ddd_csv
      end
    end

    def export_csv
      plug = CsvExportPlugin.new(@app)
      safe_export "oddb.csv" do
        plug.export_drugs
      end
      safe_export "oddb2.csv" do
        plug.export_drugs_extended
      end
    end

    def export_doc_csv
      safe_export "doctors.csv" do
        plug = CsvExportPlugin.new(@app)
        plug.export_doctors
      end
    end

    def export_fachinfo_chapter(term, chapters, lang)
      title = "Fachinfo Chapter Export"
      safe_export title do
        today = Date.today
        chapter_text = chapters.join("-")
        term_text = term.empty? ? "all" : term.gsub(/\s/, "-")
        file = today.strftime("fachinfo_chapter_#{chapter_text}_#{term_text}.%Y-%m-%d.csv")
        plug = CsvExportPlugin.new(@app)
        if plug.export_fachinfo_chapter(term, chapters, lang, file)
          if report = plug.report
            log = Log.new(today)
            log.date_str = today.strftime("%d.%m.%Y")
            log.report = report
            path = File.join(EXPORT_DIR, "#{file}.zip")
            log.files = {path => ["application/zip"]}
            log.notify(title)
          end
        end
      end
    end

    def export_generics_xls
      plug = XlsExportPlugin.new(@app)
      plug.export_generics
      plug
    end

    def export_swissdrug_xls(date = @@today, opts = {})
      plug = OuwerkerkPlugin.new(@app, "swissdrug update")
      plug.export_xls opts
      name = "swissdrug-update.xls"
      path = File.join(EXPORT_DIR, name)
      FileUtils.cp(plug.file_path, path)
      EXPORT_SERVER.compress(EXPORT_DIR, name)
      plug
    end

    def export_index_therapeuticus_csv
      safe_export "index_therapeuticus" do
        plug = CsvExportPlugin.new(@app)
        plug.export_index_therapeuticus
      end
    end

    def export_migel_csv
      plug = CsvExportPlugin.new(@app)
      plug.export_migel
    end

    def export_oddb2tdat(transfer_file = nil)
      subj = "oddb2tdat"
      safe_export(subj) do
        plug = CsvExportPlugin.new(@app)
        plug.export_oddb_dat(transfer_file)
        log = Log.new(@@today)
        log.update_values(plug.log_info)
        log.report = plug.report
        log.notify(subj)
      end
    end

    def export_oddb2tdat_with_migel(transfer_file = nil)
      subj = "oddb2tdat with migel"
      safe_export(subj) do
        plug = CsvExportPlugin.new(@app)
        plug.export_oddb_dat_with_migel(transfer_file)
        log = Log.new(@@today)
        log.update_values(plug.log_info)
        log.report = plug.report
        log.notify(subj)
      end
    end

    def export_pdf
      FiPDFExporter.new(@app).run
    end

    def export_sl_pcodes
      safe_export "sl_pcodes.txt" do
        path = File.join(WORK_DIR, "txt/sl_pcodes.txt")
        File.open(path, "w") { |fh|
          @app.each_package { |pac|
            if pac.sl_entry && pac.pharmacode
              fh.puts(pac.pharmacode)
            end
          }
        }
      end
    end

    def export_patents_xls
      plug = XlsExportPlugin.new(@app)
      plug.export_patents
      plug
    end

    def export_galenic
      exporter = YamlExporter.new(@app)
      safe_export "galenic_forms.yaml" do
        exporter.export_galenic_forms
      end
      safe_export "galenic_groups.yaml" do
        exporter.export_galenic_groups
      end
    end

    def export_yaml
      exporter = YamlExporter.new(@app)
      safe_export "oddb.yaml" do
        exporter.export
      end
      safe_export "atc.yaml" do
        exporter.export_atc_classes
      end
      safe_export "price_history.yaml" do
        exporter.export_prices
      end
      run_on_weekday(4) {
        safe_export "doctors.yaml" do
          exporter.export_doctors
        end
      }
    end

    def mail_download_stats
      safe_export "Mail Download-Statistics" do
        mail_stats("download")
      end
    end

    def mail_download_invoices
      safe_export "Mail Download-Invoices" do
        DownloadInvoicer.new(@app).run
      end
    end

    def mail_fachinfo_log(day = @@today)
      safe_export "Mail Fachinfo-Invoices" do
        plug = FachinfoInvoicer.new(@app)
        plug.run(day)
        if report = plug.report
          log = Log.new(day)
          log.date_str = day.strftime("%d.%m.%Y")
          log.report = report
          log.notify("Fachinfo-Uploads")
        end
      end
    end

    def mail_feedback_stats
      safe_export "Mail Feedback-Statistics" do
        mail_stats("feedback")
      end
    end

    def mail_patinfo_invoices
      safe_export "Mail Patinfo-Invoices" do
        PatinfoInvoicer.new(@app).run
      end
    end

    def export_price_history_csv
      safe_export "price_history.csv" do
        plug = CsvExportPlugin.new(@app)
        plug.export_price_history
      end
    end

    def export_teilbarkeit_csv
      safe_export "Teilbarkeit Export" do
        today = Date.today
        plug = CsvExportPlugin.new(@app)
        plug.export_teilbarkeit
        if report = plug.report
          log = Log.new(today)
          log.date_str = today.strftime("%d.%m.%Y")
          log.report = report
          file = today.strftime("teilbarkeit.%Y-%m-%d.csv")
          dir = File.join(WORK_DIR, "csv")
          path = File.join(dir, file)
          log.files = {path => ["text/csv"]}
          log.notify("Teilbarkeit Export")
        end
      end
    end

    def export_flickr_photo_csv
      safe_export "Flickr Ean Export" do
        today = Date.today
        plug = CsvExportPlugin.new(@app)
        plug.export_flickr_photo
        if report = plug.report
          log = Log.new(today)
          log.date_str = today.strftime("%d.%m.%Y")
          log.report = report
          file = today.strftime("flickr_ean_export.%Y-%m-%d.csv")
          dir = File.join(WORK_DIR, "csv")
          path = File.join(dir, file)
          log.files = {path => ["text/csv"]}
          log.notify("Flickr Ean Export")
        end
      end
    end

    def mail_stats(key)
      date = @@today
      if date.mday < 8
        date <<= 1
      end
      log = Log.new(date)
      begin
        log.report = File.read(LogFile.filename(key, date)) if File.exist?(LogFile.filename(key, date))
      rescue => e
        log.report = ([
          "Nothing to Report.",
          nil,
          e.class,
          e.message
        ] + e.backtrace).join("\n")
      end
      log.notify("#{key.capitalize}-Statistics")
    end

    def mail_swissmedic_notifications
      SwissmedicPlugin.new(@app).mail_notifications
    end

    def safe_export subject, &block
      logExport "safe_export #{subject} starting"
      res = block.call
      logExport "safe_export #{subject} completed"
      res
    rescue => e
      begin
        EXPORT_SERVER.clear
      rescue
        nil
      end
      log = Log.new(@@today)
      log.report = [
        "Error: #{e.class}",
        "Message: #{e.message}",
        "Backtrace:",
        e.backtrace.join("\n")
      ].join("\n")
      log.notify("Error Export: #{subject}")
      logExport "safe_export #{subject} failed"
      sleep(30)
    end
  end
end
