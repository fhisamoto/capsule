module VCAP_Services
  def self.credentials(service_name)
    raise "missing services configuration" unless ENV.include?('VCAP_SERVICES')
    services = JSON.parse(ENV['VCAP_SERVICES'])
    raise "#{service_name} not configured" if services[service_name].nil?
    services[service_name].first["credentials"]
  end
end
