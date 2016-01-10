Sidekiq.configure_server do |config|
  config.redis = { url: ENV["OPENREDIS_URL"] }
end unless ENV['OPENREDIS_URL'].blank?

Sidekiq.configure_client do |config|
  config.redis = { url: ENV["OPENREDIS_URL"] }
end unless ENV['OPENREDIS_URL'].blank?
