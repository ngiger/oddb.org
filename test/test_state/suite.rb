#!/usr/bin/env ruby

# suite.rb -- oddb.org -- 09.04.2012 -- yasaka@ywesee.com
# suite.rb -- oddb.org -- 29.03.2011 -- mhatakeyama@ywesee.com

require File.join(File.expand_path(File.dirname(__FILE__, 2)), "helpers.rb")

buggy = [
  "admin/password_lost.rb",
  "drugs/fachinfo.rb",
  "global.rb",
  "page_facade.rb"
]
runner = OddbTestRunner.new(File.dirname(__FILE__), buggy)
runner.run_isolated_tests
runner.run_normal_tests
runner.show_results_and_exit
