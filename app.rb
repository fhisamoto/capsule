require 'sinatra'

class App < Sinatra::Application
  get '/' do
    'hello world'
  end
end
