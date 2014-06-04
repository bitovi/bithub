require 'vetinari'

module FeedSupervisors
  class Irc
    include Celluloid

    def initialize(brand_name)
      @brand_name = brand_name
      @bot = init_bot

      boot
    end

    def boot
      Celluloid.logger.info "Booting IRC supervisor for brand '#{@brand_name}'"

      @bot.connect

      Celluloid.logger.info "IRCbot connected for brand '#{@brand_name}'"
    end

    private

    def config
      Celluloid::Actor[:configurator].feed_config(@brand_name, :irc)
    end

    def channels
      config.fetch(:channels) { [] }
    end

    def server
      config.fetch(:server) { 'chat.freenode.net' }
    end

    def init_bot
      bot = Vetinari::Bot.new do |c|
        c.server = server
        c.port = config.fetch(:port) { 6667 }
        c.nick = config.fetch(:nick) { "BithubBot#{rand(10_000)}" }

        # turn on logging
        c.logger = Celluloid.logger
        c.logging = true
      end

      # listen for new messages and publish
      bot.on(:channel) do |env|
        publish build_event env
      end

      # join channels
      bot.on(:connect) do
        channels.each {|c| bot.join c}
      end

      bot
    end

    def publish(event)
      Celluloid.logger.info "Publishing with brand: #{@brand_name}, feed: #{feed_name}"
      Celluloid::Actor[:publisher].publish @brand_name, feed_name, [event]
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
