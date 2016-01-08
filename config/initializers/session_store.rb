# Be sure to restart your server when you modify this file.

host, port, db = /^redis:\/\/([\d\.]+):(\d+)\/(\d+)/.match( ENV['REDIS_URL'] ).captures

Bithub::Application.config.session_store :redis_session_store, {
  key: '_session_id',
  redis: {
    host: host,
    port: port,
    db: db,
    expire_after: 1.month,
    key_prefix: 'session:'
  },
  serializer: :json
}
