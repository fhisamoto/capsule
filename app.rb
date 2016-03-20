require 'sinatra'

class App < Sinatra::Application
  get '/' do
    erb :index
  end

  post '/submit' do
    redirect '/result'
  end

  get '/result' do
    "results"
  end
end
