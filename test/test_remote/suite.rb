#!/usr/bin/env ruby

# suite.rb -- oddb -- 01.07.2011 -- yasaka@ywesee.com
# suite.rb -- oddb -- 01.07.2011 -- mhatakeyama@ywesee.com

$: << __dir__

buggy = []
require File.join(File.expand_path(File.dirname(__FILE__, 2)), "helpers.rb")
runner = OddbTestRunner.new(File.dirname(__FILE__), buggy)
runner.run_isolated_tests
runner.run_normal_tests
runner.show_results_and_exit
