require 'ruby-debug'

module Hoccer
  class FileCache < Sinatra::Base

    include Helper
    set :logging, :true

    # checking for options verb before, while it is not available in sinatra
    # should be replaced in sinatra 1.2
    before do
      
      if request.request_method == 'OPTIONS'
        response.headers["Access-Control-Allow-Origin"] = "*"
        response.headers["Access-Control-Allow-Methods"] = "POST, PUT"
        response.headers["Access-Control-Allow-Headers"] = "X-Requested-With, X-File-Name, Content-Type, Content-Disposition"

        halt 200
      end
    end

    post %r{^/(v\d)/} do |version|
      account = Account.where( :api_key => params[:api_key] ).first
      
      response.headers["Access-Control-Allow-Origin"] = params

      params.symbolize_keys!
      params[:upload].merge!(
        :expires_in => params.delete(:expires_in),
        :uuid       => UUID.generate
      )

      authorized_request do
        cached_file = CachedFile.create( params[:upload] )

        if cached_file.valid?
          host_and_port + "/#{version}/" + cached_file.uuid
        else
          halt 400
        end
      end
    end

    put %r{^/(v\d)/([a-fA-F0-9\-]{36,36})$} do |version, uuid|
      params.symbolize_keys!
          options = {
            :uuid       => uuid,
            :filename   => filename_header,
            :type       => "-",
            :expires_in => params[:expires_in],
            :tempfile   => env["rack.input"],
          }

          cached_file = CachedFile.create( options )
          if cached_file.valid?
            host_and_port + "/#{version}/" +  cached_file.uuid
          else
            puts cached_file.errors.inspect
            halt 400
          end
        end
      else 
        authorized_request do
          options = {
            :uuid       => uuid,
            :filename   => filename_header,
            :type       => "-",
            :expires_in => params[:expires_in],
            :tempfile   => env["rack.input"],
          }

          cached_file = CachedFile.create( options )
          if cached_file.valid?
            host_and_port + "/#{version}/" +  cached_file.uuid
          else
            halt 400
          end
        end        
      end

    end

    get %r{^/(v\d)/([a-fA-F0-9\-]{36,36})$} do |version, uuid|
      file = CachedFile.where(:uuid => uuid).first

      if file && file.accessible?
        send_file(
          File.join( File.dirname( __FILE__), "..", file.filepath ),
          :filename => file.original_filename
        )
      else
        halt 404
      end
    end
  end
end
