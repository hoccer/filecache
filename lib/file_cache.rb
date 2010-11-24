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

    put %r{/(.+)} do |filename|
      params.symbolize_keys!

      authorized_request do
        cached_file = CachedFile.create(
          :filename   => filename,
          :type       => "-",
          :expires_in => params[:expires_in],
          :tempfile   => env["rack.input"]
        )

        if cached_file
          host_and_port + cached_file.uuid
        else
          halt 400
        end
      end
    end

    get %r{/([a-fA-F0-9]{32,32})$} do |uuid|
      file = CachedFile.where(:uuid => uuid).first

      if file && file.accessible?
        send_file File.join( File.dirname( __FILE__), "..", file.filepath )
      else
        halt 404
      end
    end
  end
end
