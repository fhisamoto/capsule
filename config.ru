require 'bundler'
Bundler.require if defined?(Bundler)

require './config/vcap_services'
require './config/sidekiq'
require './alchemy_processor_worker'
require './app'

run App
