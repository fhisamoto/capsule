require 'open-uri'
require 'sidekiq'
require 'alchemy_api'
require 'stretcher'

require './config/vcap_services'
require './config/sidekiq'

class AlchemyProcessorWorker
  include Sidekiq::Worker

  attr_reader :page

  def apikey
    @apikey ||= VCAP_Services.credentials('alchemy_api')['apikey']
  end

  def configure_alchemy
    AlchemyAPI.configure do |config|
      config.apikey = apikey
    end
  end

  def elasticsearch
    @es ||= Stretcher::Server.new("http://#{ENV['ELASTICSEARCH_HOST']}:9200")
  end

  def perform(url)
    configure_alchemy
    puts "lalalal"
    @page = read_page(url)
    doc = {
      '_type' => 'page',
      '_id' => url,
      'text' => extract_text,
      'keywords' => extract_keywords,
      'entities' => extract_entities,
      'date' => Time.now
    }

    # create_index

    elasticsearch.index(:alchemy_processor).bulk_index [ doc ]
  end

  def create_index
    return if elasticsearch.index(:alchemy_processor).exists?
    elasticsearch.index(:alchemy_processor).create(mappings)
  end

  def mappings
    {
      mappings: {
        page: {
          dynamic: true,
          properties: {
            date: {
              type: "date",
              format: "yyyy-MM-dd'T'HH:mm:ssZ"
            }
          }
        }
      }
    }
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
