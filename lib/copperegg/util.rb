require 'pry'
require 'multi_json'

module CopperEgg
  class Util

    attr_accessor :apikey

    def initialize(apikey, product, apihost=nil)
      @apikey = apikey
      @product = product
      if apihost
        @apihost = apihost
      else
        @apihost = DEFAULTS[:apihost]
      end
    end

    def make_api_get_request(api_cmd, apikey, params)
      response = make_api_request("get", api_cmd, apikey, params)
      return response
    end

    def make_api_post_request(api_cmd, apikey, body)
      response = make_api_request("post", api_cmd, apikey, body)
      return response
    end

    private

    def make_uri(api_cmd)
      return URI.parse("#{@apihost}/#{API_VERSION}/#{@product}#{api_cmd}")
    end

    def make_api_request(type, api_cmd, apikey, params)
      request = nil
      uri = make_uri(api_cmd)
      http = Net::HTTP.new(uri.host, uri.port)
      # Download bundle from curl http://curl.haxx.se/ca/cacert.pem
      http.ca_file = '/etc/ssl/cacert.pem'
      http.use_ssl = uri.scheme == 'https'
      unless DEFAULTS[:ssl_verify_peer]
        http.verify_mode = OpenSSL::SSL::VERIFY_NONE
      end

      if type == "get"
        uri.query = URI.encode_www_form(params) unless params.nil?
        request = Net::HTTP::Get.new(uri.request_uri)
      else
        request = Net::HTTP::Post.new(uri.request_uri)
        request.body = MultiJson.dump(params)
      end
      request.basic_auth(apikey, "U")
      request["Content-Type"] = "application/json"
      response = http.request(request)
      
      #uncomment for debugging
      #binding.pry      
      if response.code != "200"
        # took me a few minutes to figure out what was going on because
        # if ANY error occurs, this quietly drops it to floor. 
        # perhaps a raising an exception or JSON with message of error might be useful?
        #
        if DEFAULTS[:debug]
          puts "Apikey: #{apikey}"
          puts "Service Endpoint: #{uri.scheme}://#{http.address}#{request.path}"
          puts "Response code: #{response.code}"
          puts "Response body: #{response.body}"
       end 
        return nil
      end
      return response
    end

  end
end
