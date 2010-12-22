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
end

configure :development do
  puts ">>>>>>>>>>>>>>>> DEVELOPMENT <<<<<<<<<<<<<<<<<"
end

configure :test do
  puts ">>>>>>>>>>>>>>>> TEST <<<<<<<<<<<<<<<<<"
end

file_name = File.join(File.dirname(__FILE__), "config", "mongoid.yml")
@settings = YAML.load_file( file_name )

Mongoid.configure do |config|
  config.from_hash(@settings[ENV['RACK_ENV']])
end

