web: ./bin/unicorn_rails -c ./config/unicorn_local.rb
listener: ruby ./services/listener/kickstart.rb
crawler_poller: ruby ./services/crawler/poller/kickstart.rb
crawler_listener: ruby ./services/crawler/listener/kickstart.rb
liveservice: nodejs ./services/liveservice/server.js
#crawler_streamer: ruby ./services/crawler/streamer/kickstart.rb
worker: ./bin/sidekiq
