require 'stretcher'

class PageResource
  def server
    @es ||= Stretcher::Server.new("http://#{ENV['ELASTICSEARCH_HOST']}:9200")
  end

  def page_index
    @pi ||= server.index(:alchemy_processor)
  end

  def setup
    return if page_index.exists?
    page_index.create(mappings: mapping)
  end

  def mapping
    {
      page: {
        properties: {
          "@timestamp": {
             type: "date",
             format: "dateOptionalTime"
           },

           text: { type: 'string' },
           keywords: analysed_properties_mapping,
           entities: analysed_properties_mapping
        }
      }
    }
  end

  def analysed_properties_mapping
    {
      dynamic: true,
      properties: {
        relevance: { type: "double" },
        count: { type: "integer" },
        sentiment: {
          dynamic: true,
          properties: {
            score: { type: "double" }
          }
        }
      }
    }
  end

  def new_page(url:, text:, keywords:, entities:)
    {
      _id: url,
      _type: 'page',
      "@timestamp": DateTime.now,
      text: text,
      keywords: keywords,
      entities: entities
    }
  end

  def put(page)
    page_index.bulk_index [ page ]
  end
end
