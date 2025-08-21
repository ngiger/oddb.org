#!/usr/bin/env ruby

# ODDB::Http -- oddb.org -- 10.05.2013 -- yasaka@ywesee.com
# ODDB::Http -- oddb.org -- 09.01.2012 -- mhatakeyama@ywesee.com
# ODDB::Http -- oddb.org -- 03.12.2003 -- hwyss@ywesee.com

require "cgi"
require "net/http"
require "uri"
require "delegate"
require "fileutils"

module ODDB
  module HttpFile
    def http_file(server, source, target, session = nil, hdrs = nil)
      if (body = http_body(server, source, session, hdrs))
        dir = File.dirname(target)
        FileUtils.mkdir_p(dir)
        File.open(target, "w") { |file|
          file << body
        }
        true
      end
    end

    def http_body(server, source, session = nil, hdrs = nil)
      session ||= HttpSession.new server
      hdrs ||= {}
      resp = session.get(source, hdrs)
      if resp.is_a? Net::HTTPOK
        resp.body
      end
    end
  end

  class HttpSession < SimpleDelegator
    class ResponseWrapper < SimpleDelegator
      def initialize(resp)
        @response = resp
        super
      end

      def body
        body = @response.body
        charset = self.charset
        # content
        body = if @response["content-encoding"] == "gzip"
          begin
            Zlib::GzipReader.new(StringIO.new(body), encoding: "ASCII-8BIT").read
          rescue Zlib::GzipFile::Error, Zlib::Error # actually this is not gzip :(
            body
          end
        else
          body
        end
        if charset.nil? || charset.downcase != "utf-8"
          begin
            body.encode("UTF-8", invalid: :replace, undef: :replace, replace: "?")
          rescue
            body
          end
        else
          body
        end
      end

      def charset
        if (ct = @response["Content-Type"]) \
          && (match = /charset=([^;])+/u.match(ct))
          arr = match[0].split("=")
          arr[1].strip.downcase
        end
      end
    end
    HTTP_CLASS = Net::HTTP
    RETRIES = 3
    RETRY_WAIT = 10
    def initialize(http_server, port = 80)
      @http_server = http_server
      @http = self.class::HTTP_CLASS.new(@http_server, port)
      @output = ""
      super(@http)
    end

    def post(path, hash)
      retries = RETRIES
      headers = post_headers
      begin
        # @http.set_debug_output($stderr)
        resp = @http.post(path, post_body(hash), headers)
        case resp
        when Net::HTTPOK
          ResponseWrapper.new(resp)
        when Net::HTTPFound
          uri = URI.parse(resp["location"])
          path = uri.respond_to?(:request_uri) ? uri.request_uri : uri.to_s
          warn(sprintf("redirecting to: %s", path))
          get(path)
        else
          raise("could not connect to #{@http_server} #{path}: #{resp}")
        end
      rescue Errno::ECONNRESET, EOFError
        if retries > 0
          retries -= 1
          sleep RETRIES - retries
          retry
        else
          raise
        end
      end
    end

    def post_headers
      headers = get_headers
      headers.push(["Content-Type", "application/x-www-form-urlencoded"])
      headers.push(["Referer", @referer.to_s])
    end

    def get(*args)
      retries = RETRIES
      begin
        @http.get(*args)
      rescue Errno::ECONNRESET, Errno::ECONNREFUSED, EOFError
        if retries > 0
          retries -= 1
          sleep RETRIES - retries
          retry
        else
          raise
        end
      end
    end

    def get_headers
      [
        ["Host", @http_server],
        ["User-Agent", "Mozilla/5.0 (X11; Linux x86_64; rv:20.0) Gecko/20100101 Firefox/20.0"],
        ["Accept", "text/xml,application/xml,application/xhtml+xml,text/html;q=0.9,text/plain;q=0.8,video/x-mng,image/png,image/jpeg,image/gif;q=0.2,*/*;q=0.1"],
        ["Accept-Encoding", "gzip, deflate"],
        ["Accept-Language", "de-ch,en-us;q=0.7,en;q=0.3"],
        ["Accept-Charset", "UTF-8"],
        ["Keep-Alive", "300"],
        ["Connection", "keep-alive"]
      ]
    end

    def post_body(data)
      sorted = data.collect { |pair|
        pair.collect { |item| CGI.escape(item) }.join("=")
      }
      sorted.join("&")
    end
  end
end
