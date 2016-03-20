require 'sinatra'

class App < Sinatra::Application
  get '/' do
    erb :index
  end

  post '/submit' do
    puts params['feed_url']
    AlchemyProcessorWorker.perform_async(params['feed_url'])
    redirect '/result'
  end

  get '/result' do
    "results"
  end
end
