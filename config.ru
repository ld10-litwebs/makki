require 'bundler'
require 'dotenv'
Bundler.require

require './app'

Dotenv.load

Cloudinary.config do |config|
  config.cloud_name = "dl5gzuv3t"
  config.api_key    = "574591183297471"
  config.api_secret = "jsugOs833u-5PSEYppiy-SUdxdg"
end

run Sinatra::Application
