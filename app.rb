require 'sinatra'

class App < Sinatra::Application
  get '/' do
    erb :index
  end

  post '/submit' do
    Sidekiq::Client.enqueue('AlchemyProcessorWorker', params['feed_url'])
    redirect '/result'
  end

  get '/result' do
    "results"
  end
end
