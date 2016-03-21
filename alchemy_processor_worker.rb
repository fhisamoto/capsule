require 'open-uri'
require 'sidekiq'
require 'alchemy_api'
require 'stretcher'

require './config/vcap_services'
require './config/sidekiq'
require './config/elasticsearch'

def apikey
  @apikey ||= VCAP_Services.credentials('alchemy_api')['apikey']
end

AlchemyAPI.configure do |config|
  config.apikey = apikey
end

class AlchemyProcessorWorker
  include Sidekiq::Worker

  attr_reader :page

  def elasticsearch
    @es ||= Stretcher::Server.new("http://#{ELASTICSEARCH_HOST}:9200")
  end

  def perform(url)
    @page = read_page(url)
    doc = {
      '_type' => 'alchemy',
      '_id' => url,
      'text' => extract_text,
      'keywords' => extract_keywords,
      'entities' => extract_entities,
      '@timestamp' => Time.now.utc
    }
    elasticsearch.index(:alchemy).bulk_index [ doc ]
  end

  def extract_text
    AlchemyAPI::TextExtraction.new.search(html: page)
  end

  def extract_keywords
    AlchemyAPI::KeywordExtraction.new.search(html: page)
  end

  def extract_entities
    AlchemyAPI::EntityExtraction.new.search(html: page)
  end

  def read_page(url)
    URI.parse(url).read
  end
end
