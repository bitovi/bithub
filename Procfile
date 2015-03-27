web: ./bin/unicorn_rails -c ./config/unicorn_local.rb
listener: ruby ./services/listener/listener.rb
crawler_poller: NEW_RELIC_APP_NAME="crawler" ruby ./services/crawler/poller/kickstart.rb
crawler_listener: NEW_RELIC_APP_NAME="crawler" ruby ./services/crawler/listener/kickstart.rb
#crawler_streamer: ruby ./services/crawler/streamer/kickstart.rb
worker: ./bin/sidekiq
liveservice: nodejs ./services/liveservice/server.js
