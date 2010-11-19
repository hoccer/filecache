require 'ruby-debug'

module Hoccer
  class FileCache < Sinatra::Base

    include Helper

    post '/' do
      params.symbolize_keys!
      params[:upload].merge!( :expires_in => params.delete(:expires_in) )

      authorized_request do
        cached_file = CachedFile.create( params[:upload] )

        host_and_port + cached_file.uuid
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
