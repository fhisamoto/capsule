require 'open-uri'
require 'sidekiq'

class AlchemyProcessorWorker
  include Sidekiq::Worker

  attr_reader :page

  def perform(url)
    @page = read_page(url)
    doc = {
      text: extract_text,
      keywords: extract_keywords,
      entities: extract_entities
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
