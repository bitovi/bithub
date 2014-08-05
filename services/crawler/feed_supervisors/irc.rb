require 'vetinari'

module FeedSupervisors
  class Irc
    include Celluloid

    def initialize(brand_name)
      @brand_name = brand_name
      @bots = []

      boot
    end

    def boot
      Celluloid.logger.info "Booting IRC supervisor for brand '#{@brand_name}'"

      chats.each do |c|
        server = c.fetch(:server) { 'chat.freenode.net' }
        channel = c.fetch(:channel)
        decorator = Decorators::Irc.new c

        unless bot = match_bot_by_server(server)
          bot = init_bot(server)
          @bots << bot
        end

        bot.on(:connect) { bot.join channel }
        bot.on(:channel) do |env|
          publish(build_event(env), decorator) if env[:channel].name == channel
        end
      end

      @bots.each {|b| b.async.connect}

      Celluloid.logger.info "IRCbot connected for brand '#{@brand_name}'"
    end

    private

    def match_bot_by_server(server)
      @bots.select {|b| b.config.server == server}.first
    end

    def config
      Celluloid::Actor[:configurator].feed_config(@brand_name, :irc)
    end

    def chats
      config.fetch(:chats) { [] }
    end

    def init_bot(server, opts = {})
      Vetinari::Bot.new do |c|
        c.server = server
        c.port = config.fetch(:port) { 6667 }
        c.nick = config.fetch(:nick) { "BithubBot#{rand(10_000)}" }

        # turn on logging
        c.logger = Celluloid.logger
        c.logging = true

        # keep console quite
        c.verbose = false
      end
    end

    def publish(event, decorator)
      Celluloid.logger.info "Publishing with brand: #{@brand_name}, feed: #{feed_name}"
      Celluloid::Actor[:publisher].publish @brand_name, feed_name, [event], decorator: decorator
    end

    def feed_name
      'irc'
    end

    def actor_name
      "#{@brand_name}_irc_#{server.snake_case}".to_sym
    end

    def build_event(env)
      {
        channel: env[:channel].name,
        nickname: env[:nick],
        message: env[:message],
        ts: Time.now.utc
      }
    end

  end
end
