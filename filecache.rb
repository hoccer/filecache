$LOAD_PATH.unshift(File.dirname(__FILE__))

require 'sinatra'
require 'cached_file'
require 'fileutils'
require 'uuid'

post '/' do
  datafile          = params[:data]

  first_level_dir   = rand(65535).to_s(16).rjust(4, "0")
  second_level_dir  = rand(65535).to_s(16).rjust(4, "0")

  file_dir          = File.join("files", first_level_dir, second_level_dir)

  FileUtils.mkdir_p( file_dir )

  uuid              = UUID.generate(:compact)
  extension         = File.extname( datafile[:filename] )
  file_path         = File.join( file_dir, uuid ) + extension

  File.open(file_path, 'wb') do |file|
    file.write(datafile[:tempfile].read)
  end

  CachedFile.create(
    :uuid               => uuid,
    :original_filename  => datafile[:filename],
    :filepath          => file_path,
    :content_type       => datafile[:type],
    :created_at         => Time.now,
    :expires_at         => Time.now + 7.seconds
  )
end

get %r{/([a-fA-F0-9]{32,32})$} do |uuid|
  file = CachedFile.where(:uuid => uuid).first

  if file
    send_file File.join( File.dirname( __FILE__), file.filepath )
  else
    halt 404
  end
end
