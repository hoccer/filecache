require 'ruby-debug'

module Hoccer
  class FileCache < Sinatra::Base

    include Helper

    post '/' do
      params.symbolize_keys!
      params[:upload].merge!( :expires_in => params.delete(:expires_in) )

      authorized_request do
        cached_file = CachedFile.create( params[:upload] )

        if cached_file
          host_and_port + cached_file.uuid
        else
          halt 400
        end
      end
    end

    put %r{/([a-fA-F0-9\-]{36,36})$} do |uuid|
      params.symbolize_keys!

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
          host_and_port + cached_file.uuid
        else
          halt 400
        end
      end
    end

    get %r{/([a-fA-F0-9\-]{36,36})$} do |uuid|
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
