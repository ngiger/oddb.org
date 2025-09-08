#!/usr/bin/env ruby

# View::Login -- oddb -- hwyss@ywesee.com

require "view/publictemplate"
require "view/logohead"
require "view/admin/logincomposite"

module ODDB
  module View
    module Admin
      class Login < View::PublicTemplate
        CONTENT = View::Admin::LoginComposite
        HEAD = View::WelcomeHead
      end
    end
  end
end
