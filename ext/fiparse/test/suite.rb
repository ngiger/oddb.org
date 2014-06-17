#!/usr/bin/env ruby
# suite.rb -- oddb -- 08.09.2006 -- hwyss@ywesee.com 

$: << File.expand_path(File.dirname(__FILE__))

buggy =  []
require File.join(File.expand_path(File.dirname(File.dirname(__FILE__))), '../../test/helpers.rb')
runner = OddbTestRunner.new(File.dirname(__FILE__), buggy)
runner.run_isolated_tests
runner.run_normal_tests
runner.show_results_and_exit
