module VCAP_Services
  def self.credentials(service_name)
    raise "missing services configuration" unless ENV.include?('VCAP_SERVICES')
    services = JSON.parse(ENV['VCAP_SERVICES'])
    raise "alchemy api not configured" if services['alchemy_api'].nil?
    services[service_name].first["credentials"]
  end
end