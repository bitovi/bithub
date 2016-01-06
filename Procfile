rails: bundle exec puma -C ./config/puma.rb
sidekiq: bundle exec sidekiq

persistor: bundle exec ruby ./services/guzzler/persistor
poller: bundle exec ruby ./services/guzzler/poller
liveservice: node ./services/liveservice/server.js

#ssr: cd ./public/new-bithub-client && ./node_modules/can-ssr/bin/can-serve --port 3030
#crawler_listener: bundle exec ruby ./services/crawler/listener/kickstart.rb
#crawler_streamer: bundle exec ruby ./services/crawler/streamer/kickstart.rb
