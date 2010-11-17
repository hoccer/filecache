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
end
