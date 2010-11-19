require 'ruby-debug'

module Hoccer
  class FileCache < Sinatra::Base

    include Helper

    post '/' do
      authorized_request do
        CachedFile.create params[:data]
      end
    end

    get %r{/([a-fA-F0-9]{32,32})$} do |uuid|
      file = CachedFile.where(:uuid => uuid).first

      if file
        send_file File.join( File.dirname( __FILE__), "..", file.filepath )
      else
        halt 404
      end
    end
  end
end
