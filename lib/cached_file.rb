require 'mongoid'

class CachedFile
  include Mongoid::Document

  Mongoid.configure do |config|
    name = "hoccer_development"
    host = "localhost"
    config.master = Mongo::Connection.new.db(name)
    config.persist_in_safe_mode = true
  end

  field :api_key
  field :original_filename
  field :filepath
  field :content_type
  field :created_at,  :type => DateTime
  field :expires_at,  :type => DateTime


  def self.create options
    uuid              = UUID.generate(:compact)
    extension         = File.extname( options[:filename] )
    file_path         = File.join( file_dir, uuid ) + extension

    File.open(file_path, 'wb') do |file|
      file.write(options[:tempfile].read)
    end

    super(
      :uuid               => uuid,
      :original_filename  => options[:filename],
      :filepath           => file_path,
      :content_type       => options[:type],
      :created_at         => Time.now,
      :expires_at         => Time.now + 7.seconds
    )
  end

  def self.file_dir
    first_level_dir   = rand(65535).to_s(16).rjust(4, "0")
    second_level_dir  = rand(65535).to_s(16).rjust(4, "0")
    file_dir          = File.join("files", first_level_dir, second_level_dir)

    FileUtils.mkdir_p( file_dir )

    file_dir
  end
end
