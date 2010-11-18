module Hoccer

  module Helper

    def valid_request?
      account   = Account.where( :api_key => params["api_key"] ).first

      return false if account.nil?

      signature = params.delete("signature")
      uri       = env['REQUEST_URI'].gsub(/\&signature\=.+$/, "")

      digestor = Digest::HMAC.new(account["shared_secret"], Digest::SHA1)
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
  end

end
