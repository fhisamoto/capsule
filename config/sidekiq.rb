require 'sidekiq'

def redis_url
  c = VCAP_Services.credentials('rediscloud')
  return "redis://#{c['password']}@#{c['hostname']}:#{c['port']}" if c['password']

  "redis://#{c['hostname']}:#{c['port']}"
end

Sidekiq.configure_server do |config|
  config.redis = { url: redis_url }
end

Sidekiq.configure_client do |config|
  config.redis = { url: redis_url }
end
