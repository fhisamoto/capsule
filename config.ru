require 'bundler'
Bundler.require if defined?(Bundler)

require './app'

run Sinatra::Application
