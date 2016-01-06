# Be sure to restart your server when you modify this file.

Bithub::Application.config.session_store :redis_session_store, {
  key: '_session_id',
  redis: {
    url: ENV.fetch('REDIS_URL'),
    expire_after: 1.month,
    key_prefix: 'session:',
  },
  serializer: :json
}
