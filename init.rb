require 'sinatra'
require 'mongoid'
require 'account'
require 'helper'
require 'file_cache'
require 'cached_file'
require 'fileutils'
require 'uuid'

configure :production do
  puts ">>>>>>>>>>>>>>>> PRODUCTION <<<<<<<<<<<<<<<<<"
  Mongoid.configure do |config|
    name = "hoccer_development"
    host = "localhost"
    config.master = Mongo::Connection.new.db(name)
    config.persist_in_safe_mode = true
  end
end

configure :development do
  puts ">>>>>>>>>>>>>>>> DEVELOPMENT <<<<<<<<<<<<<<<<<"
  Mongoid.configure do |config|
    name = "hoccer_development"
    host = "localhost"
    config.master = Mongo::Connection.new.db(name)
    config.persist_in_safe_mode = true
  end
end

configure :test do
  puts ">>>>>>>>>>>>>>>> TEST <<<<<<<<<<<<<<<<<"
  Mongoid.configure do |config|
    name = "hoccer_test"
    host = "localhost"
    config.master = Mongo::Connection.new.db(name)
    config.persist_in_safe_mode = true
  end
end
