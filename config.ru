require 'bundler'
Bundler.require if defined?(Bundler)

require './config/alchemy_api'
require './app'

run App
