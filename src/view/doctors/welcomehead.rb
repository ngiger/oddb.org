#!/usr/bin/env ruby

# View::Doctors::Init -- oddb -- 17.09.2004 -- usenguel@ywesee.com, jlang@ywesee.com

require "htmlgrid/composite"
require "htmlgrid/text"
require "htmlgrid/link"
# require 'htmlgrid/flash'
require "view/logo"

module ODDB
  module View
    module Doctors
      class WelcomeHeadDoctors < View::WelcomeHead
      end
    end
  end
end
