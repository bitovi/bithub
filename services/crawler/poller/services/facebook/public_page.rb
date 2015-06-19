require 'services/intervals'

module Supervisors::Services::Facebook
  class PublicPage < Supervisors::Service

    def boot
      @endpoints.supervise_as(
        @path.next_level(NodeTypes::EndpointInfo.new('public_page', page_id)).actor_name,
        Poller, *[
          @path,
          Fetchers::Facebook::GetFeed.new(client, { object_id: page_id }),
          { interval: Intervals::Poller::FACEBOOK_FEED }
        ])
    end

    private

    def client
      Koala::Facebook::API.new access_token
    end

    def access_token
      service_config.fetch(:access_token) { "#{ENV['FACEBOOK_CLIENT_ID']}|#{ENV['FACEBOOK_CLIENT_SECRET']}" }
    end

    def page_id
      service_config.fetch(:id)
    end

  end
end
