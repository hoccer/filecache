module Hoccer

  module Helper

    def valid_request?
      puts env['REQUEST_URI']
      account   = Account.where( :api_key => params[:api_key] ).first

      return false if account.nil?

      signature = params.delete(:signature)
      uri       = env['REQUEST_URI'].gsub(/\&signature\=.+$/, "")

      digestor = Digest::HMAC.new(account[:shared_secret], Digest::SHA1)
      computed_signature = digestor.base64digest(uri)

      signature == computed_signature
    end

    def authorized_request &block
      if ENV["RACK_ENV"] == "production"
        if valid_request?
          block.call
        else
          halt 401
        end
      else
        block.call
      end
    end

    def port
      if request.scheme == "http" && request.port == "80"
        ""
      elsif request.scheme == "https" && request.port == "443"
        ""
      else
        ":#{request.port}"
      end
    end

    def host_and_port
      "#{request.scheme}://#{request.host}#{port}/"
    end
  end

end
