Sidekiq.configure_server do |config|
  config.redis = { url: ENV['REDIS_URL'] }
  Sidekiq::BasicFetch::TIMEOUT = 60
end

Sidekiq.configure_client do |config|
  config.redis = { url: ENV['REDIS_URL'] }
end
