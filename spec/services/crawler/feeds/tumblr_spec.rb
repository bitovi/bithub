require_relative 'feeds_helper'

require 'events/tumblr/post'
require 'fetchers/tumblr/posts'
require 'supervisors/support/owner_data'

describe Fetchers::Tumblr::Posts  do

  ### Init / cleanup

  before do
    Celluloid.boot
    Celluloid::Actor[:publisher] = Publisher.new reject_old: false

    rabbitmq_uri = ENV['RABBITMQ_URI']

    @rabbit = Bunny.new(rabbitmq_uri)
    @rabbit.start
    @chan = @rabbit.create_channel

    @x = @chan.direct('x.web')
    @q = @chan.queue('q.web.events').bind(@x)

    @owner_data = OwnerData.new 1, 'foo', 2, 'bar', 3, 'tumblr', 'post'
  end

  after do
    Celluloid.shutdown
    @rabbit.close
  end

  ### Tests

  describe "#fetch" do
    it "queries Tumblr API, dispatches and publishes events" do

      VCR.use_cassette('tumblr_posts') do
        response = Fetchers::Tumblr::Posts.fetch 'puuluu.tumblr.com', limit: 1
        Celluloid::Actor[:publisher].publish @owner_data, response
      end

      # wait for an event on MQ
      c = @q.subscribe(block: true) do |delivery_info, metadata, payload|
        parsed = JSON.parse payload

        expect(parsed['content_digest'].length).to eq(32)

        expect(parsed['meta']['feed_name']).to eq('tumblr')
        expect(parsed['meta']['type_name']).to eq('post')
        expect(parsed['meta']['brand_id']).to eq(1)
        expect(parsed['meta']['brand_name']).to eq('foo')
        expect(parsed['meta']['embed_id']).to eq(2)
        expect(parsed['meta']['embed_name']).to eq('bar')

        @rabbit.close
      end

    end
  end
end
