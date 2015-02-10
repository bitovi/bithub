web: ./bin/unicorn_rails -c ./config/unicorn_local.rb
listener: ruby ./services/listener/listener.rb
crawler: ruby ./services/crawler/crawler.rb
crawler_listener: ruby ./services/crawler/listener/listener.rb
worker: ./bin/sidekiq
liveservice: nodejs ./services/liveservice/server.js
