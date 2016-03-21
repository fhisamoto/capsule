require 'bundler'
Bundler.require if defined?(Bundler)

require './config/vcap_services'
require './config/sidekiq'
require './app'

run App
