require 'mongoid'

class CachedFile
  include Mongoid::Document

  field :uuid
  field :api_key
  field :original_filename
  field :filepath
  field :content_type
  field :created_at,  :type => DateTime
  field :expires_at,  :type => DateTime

  validates_uniqueness_of :uuid
  validates_presence_of   :uuid, :filepath, :original_filename

  def self.write_file uuid, options
    return nil unless options[:filename]

    if options[:tempfile] && options[:tempfile].respond_to?(:read)
      file = options[:tempfile]
    else
      return false
    end

    extension   = File.extname( options[:filename] )
    file_path   = File.join( file_dir, uuid ) + extension

    File.open(file_path, 'wb') do |file|
      file.write(options[:tempfile].read)
    end

    file_path
  end

  def self.create options
    file_path   = write_file( options[:uuid], options )
    expires_in  = options[:expires_in] ? options[:expires_in].to_i : 7

    super(
      :uuid               => options[:uuid],
      :original_filename  => options[:filename],
      :filepath           => file_path,
      :content_type       => options[:type],
      :created_at         => Time.now,
      :expires_at         => Time.now + expires_in.seconds
    )
  end

  def self.file_dir
    first_level_dir   = rand(65535).to_s(16).rjust(4, "0")
    second_level_dir  = rand(65535).to_s(16).rjust(4, "0")
    file_dir          = File.join("files", first_level_dir, second_level_dir)

    FileUtils.mkdir_p( file_dir )

    file_dir
  end

  def accessible?
    Time.now.to_i < expires_at.to_i
  end

  def absolute_filepath
    File.join(
      File.dirname(__FILE__),
      "..",
      filepath
    )
  end
end
