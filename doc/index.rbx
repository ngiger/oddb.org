#!/usr/bin/env ruby
# index.rbx -- oddb.org -- 27.09.2012 -- yasaka@ywesee.com
# index.rbx -- oddb.org -- 21.02.2012 -- mhatakeyama@ywesee.com
# index.rbx -- oddb.org -- hwyss@ywesee.com

require "rubygems"
require "sbsm/request"
require "util/oddbconfig"

DRb.start_service("druby://localhost:0")

begin
  request = SBSM::Request.new(ODDB::SERVER_URI)
  if request.is_crawler?
    request = if /google/i.match?(request.cgi.user_agent)
      SBSM::Request.new(ODDB::SERVER_URI_FOR_GOOGLE_CRAWLER)
    else
      SBSM::Request.new(ODDB::SERVER_URI_FOR_CRAWLER)
    end
  end
  request.process
rescue Exception => e
  $stderr << "ODDB-Client-Error: " << e.message << "\n"
  $stderr << e.class << "\n"
  $stderr << e.backtrace.join("\n") << "\n"
end
