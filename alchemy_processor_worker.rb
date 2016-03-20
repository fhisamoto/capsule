require 'open-uri'
require 'sidekiq'
require './config/vcap_services'
require './config/sidekiq'
require './config/elasticsearch'
require './config/alchemy_api'

class AlchemyProcessorWorker
  include Sidekiq::Worker

  attr_reader :page

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
    ES.index(:alchemy).bulk_index [ doc ]
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
