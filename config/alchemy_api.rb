
require 'alchemy_api'

AlchemyAPI.configure do |config|
  config.apikey = VCAP_Services.credentials('alchemy_api')['apikey']
end
