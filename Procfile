web: ./bin/unicorn_rails -c ./config/unicorn_local.rb
listener: ruby ./services/listener/listener.rb
crawler_poller: NEW_RELIC_APP_NAME="Bithub-Crawler/Poller (Development)" ruby ./services/crawler/poller/kickstart.rb
#crawler_listener: NEW_RELIC_APP_NAME="Bithub-Crawler/Listener (Development)" ruby ./services/crawler/listener/kickstart.rb
liveservice: NEW_RELIC_APP_NAME="Bithub-LiveService (Development)" nodejs ./services/liveservice/server.js
#crawler_streamer: ruby ./services/crawler/streamer/kickstart.rb
#worker: ./bin/sidekiq
