#!/usr/bin/env ruby

# suite.rb -- oddb.org -- 09.04.2012 -- yasaka@ywesee.com
# suite.rb -- oddb.org -- 30.06.2011 -- mhatakeyama@ywesee.com
buggy = []
require File.join(File.expand_path(File.dirname(__FILE__, 2)), "helpers.rb")
runner = OddbTestRunner.new(File.dirname(__FILE__), buggy)
runner.run_isolated_tests
runner.run_normal_tests
runner.show_results_and_exit
