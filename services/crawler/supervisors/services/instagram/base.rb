require 'instagram'
require 'active_support/core_ext/string'

module Supervisors::Services::Instagram
  class Base < Supervisors::Service
    VALID_OBJECTS = %w(user tag location geography)

    def boot
      # cleanup existing subscriptions
      #delete_subscriptions

      Celluloid.logger.info "Creating Instagram #{self.class} subscription #{@path.brand.name}->#{@path.embed.name} with #{service_config}"
      begin
        subscribe service_config
      rescue ::Instagram::Error => e
        Celluloid.logger.info "Instagram subscription failed with #{e.message}"
      end
    end

    def token
      service_config.fetch(:access_token)
    end

    private

    def delete_subscriptions
      client.subscriptions.each do |sub|
        Celluloid.logger.info "Deleting Instagram subscription #{sub.id}"
        client.delete_subscription sub.id
      end
    end

    def client
      @client ||= ::Instagram.client client_id: ENV['INSTAGRAM_CLIENT_ID'], client_secret: ENV['INSTAGRAM_CLIENT_SECRET']
    end

    def callback_url(opts={})
      domain = opts[:domain] || ENV['CRAWLER_HTTP_DOMAIN']
      port   = opts[:port]   || ENV['CRAWLER_HTTP_PORT']
      path   = File.join ENV['CRAWLER_HTTP_PREFIX'], 'instagram', 'media', "#{@path.brand.id}-#{@path.brand.name}", "#{@path.embed.id}-#{@path.embed.name}", "#{@path.service.id}"

      "http://#{domain}:#{port}#{path}"
    end

  end
end
