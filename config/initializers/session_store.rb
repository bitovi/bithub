# Be sure to restart your server when you modify this file.

Bithub::Application.config.session_store :redis_session_store, {
  key: '_session_id',
  url: ENV['REDIS_URL'],
  serializer: :json
}
