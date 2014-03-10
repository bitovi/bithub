web: ./bin/unicorn_rails -c ./config/unicorn_local.rb
worker: ./script/delayed_job run
listener: ruby ./services/listener/listener.rb
crawler: ruby ./services/crawler/crawler.rb
# irc_bot: ruby ./services/irc_bot/irc_bot.rb
# liveservice: node ./services/liveservice/app/app.js
# xmpp_bot: ruby ./services/xmpp-bot/app/xmpp_bot.rb
