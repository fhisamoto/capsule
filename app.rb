require 'sinatra'

class App < Sinatra::Application
  get '/' do
    erb :index
  end

  post '/submit' do
    Sidekiq::Client.enqueue(AlchemyProcessorWorker, params['feed_url'])
    redirect '/result'
  end

  def kibana_url
    "http://#{ENV['KIBANA_HOST']}:5601/app" + '/kibana#/discover'
  end

  get '/result' do
    erb :result, locals: { kibana_url: kibana_url }
  end
end
