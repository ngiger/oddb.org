#!/usr/bin/env ruby

# FiPDFExporter -- ODDB -- 13.02.2004 -- hwyss@ywesee.com

require "plugin/plugin"
require "util/oddbconfig"
require "util/searchterms"
require "drb"
require "model/fachinfo"
require "delegate"

module ODDB
  class FiPDFExporter < Plugin
    WRITER = DRbObject.new(nil, FIPDF_URI)
    PDF_PATH = File.join(ODDB::WORK_DIR, "downloads")
    def run
      write_pdf
    end

    def write_pdf(language = :de, path = nil, fachinfos = nil)
      path ||= File.expand_path("fachinfos.pdf", PDF_PATH)
      fachinfos ||= @app.fachinfos.values
      ids = fachinfos.collect { |fi| fi.odba_id }
      WRITER.write_pdf ids, language, path
    end
  end
end
