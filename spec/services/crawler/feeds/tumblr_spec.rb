require_relative 'feeds_helper'

require 'events/tumblr/post'
require 'fetchers/tumblr/posts'

describe Fetchers::Tumblr::Posts  do

  ### Init / cleanup

  before do
    Celluloid.boot
    Celluloid::Actor[:publisher] = Publisher.new reject_old: false

    rabbitmq_uri = ENV['RABBITMQ_URI']

    @rabbit = Bunny.new(rabbitmq_uri)
    @rabbit.start
    @chan = @rabbit.create_channel

    @x = @chan.direct("x.events")
    @q = @chan.queue("q.events").bind(@x)
  end

  after do
    Celluloid.shutdown
    @rabbit.close
  end

  ### Tests

  describe "#fetch" do
    it "queries Tumblr API, dispatches and publishes events" do

      posts_raw = File.new("spec/support/responses/tumblr/posts_raw_http")
      brand_name    = 'bitovi'

      stub_request(:get, /.*api\.tumblr\.com.*/).to_return posts_raw

      response = Fetchers::Tumblr::Posts.fetch 'puuluu.tumblr.com', limit: 1
      Celluloid::Actor[:publisher].publish brand_name, :tumblr, response

      # wait for an event on MQ
      c = @q.subscribe(block: true) do |delivery_info, metadata, payload|
        parsed = JSON.parse payload

        expect(parsed['content_digest'].length).to eq(32)

        expect(parsed['meta']['feed_name']).to eq('tumblr')
        expect(parsed['meta']['type_name']).to eq('post')
        expect(parsed['meta']['brand_name']).to eq(brand_name)

        # expect(parsed['source_data']).to eq(text_post)

        @rabbit.close
      end

    end
  end

end
