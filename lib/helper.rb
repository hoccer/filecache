module Hoccer

  module Helper

    def protocol_and_host
      scheme = request.env["HTTP_X_FORWARDED_PROTO"] || request.scheme
      "#{scheme}://#{request.host}"
    end

    def request_uri
      uri_without_signature = env['REQUEST_URI'].gsub(/\&signature\=.+$/, "")

      if env['REQUEST_URI'] =~ /^http\:\/\//
        uri_without_signature
      else
        protocol_and_host + uri_without_signature
      end
    end

    def valid_request?
      account   = Account.where( :api_key => params[:api_key] ).first
      return false if account.nil?

      signature = params.delete(:signature)
      digestor = Digest::HMAC.new(account[:shared_secret], Digest::SHA1)
      computed_signature = digestor.base64digest(request_uri)

      signature == computed_signature
    end

    def authorized_request &block
      if (request.env['HTTP_ORIGIN']) 
        account = Account.where( :api_key => params[:api_key] ).first
        if account.websites.include? request.env['HTTP_ORIGIN']
          response.headers["Access-Control-Allow-Origin"] = request.env['HTTP_ORIGIN']
          block.call
        else
          halt(
            401,
            {'Content-Type' => 'application/json' },
            {:error => "Invalid API Key or Signature"}.to_json
          )
        end
      elsif ENV["RACK_ENV"] == "production"
        if valid_request?
          block.call
        else
          halt(
            401,
             {'Content-Type' => 'application/json' },
             {:error => "Invalid API Key or Signature"}.to_json
          )
        end
      else
        block.call
      end
    end

    def port
      if [80, 443].include?( request.port )
        ""
      else
        ":#{request.port}"
      end
    end

    def host_and_port
      "#{protocol_and_host}#{port}"
    end

    def filename_header
      begin
        request.env["HTTP_CONTENT_DISPOSITION"].scan(
          /filename\=\"(.+)\"/
        ).flatten.first
      rescue => e
        puts "!!!!!! #{e.message}"
        nil
      end
    end
  end

end
