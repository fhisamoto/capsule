require 'alchemy_api'

def alchemy_api_credentials
  raise "missing services configuration" unless ENV.include?('VCAP_SERVICES')
  services = JSON.parse(ENV['VCAP_SERVICES'])
  raise "alchemy api not configured" if services['alchemy_api'].nil?
  services['alchemy_api'].first["credentials"]
end

AlchemyAPI.configure do |config|
config.apikey = alchemy_api_credentials['apikey']
end
