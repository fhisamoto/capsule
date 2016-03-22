require 'open-uri'
require 'alchemy_api'

require './config/vcap_services'
require './config/sidekiq'
require './repositories/page_repository'

class AlchemyProcessorWorker
  include Sidekiq::Worker

  def apikey
    @apikey ||= VCAP_Services.credentials('alchemy_api')['apikey']
  end

  def configure_alchemy
    AlchemyAPI.configure do |config|
      config.apikey = apikey
    end
  end

  def page_resource
    @resource ||= Repositories::PageRepository.new
  end

  def perform(url)
    read_page(url)
    configure_alchemy
    page_resource.setup
    doc = page_resource.new_page(url: url,
                                 text: extract_text,
                                 keywords: extract_keywords,
                                 entities: extract_entities)
    page_resource.put(doc)
  end

  attr_reader :page

  def read_page(url)
    @page = URI.parse(url).read
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
end
