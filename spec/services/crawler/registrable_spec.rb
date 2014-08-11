require 'spec_helper'
require 'services/crawler/streamer/registrable'

module Streamers
  class GetMyData
    include Celluloid
    include Registrable
    def initialize
      @restarted = false
    end
    def connect
      @restarted = true
    end
    def reconnect
      @restarted = true
    end
    def registration_timeout
      1
    end
    attr_reader :restarted
  end
end

describe Streamers::Registrable do
  before { Celluloid.boot }
  after { Celluloid.shutdown }

  let(:channel) do
    double("channel", :name => "nikica", :topics => %w(canjs jquery))
  end

  let(:channel2) do
    double("channel2", :name =>"veljko", :topics => %w(javascriptmvc what))
  end

  describe "#register" do
    it "adds the channel to list of subscribers" do
      s = Streamers::GetMyData.new
      s.register channel
      expect(s.channels).to include(channel)
    end
  end

  describe "#unregister" do
    it "removes the channel from the list of subscribers" do
      s = Streamers::GetMyData.new
      s.register channel
      expect{ s.unregister(channel.name) }.to change{ s.channels }.from([channel]).to([])
    end
  end

  describe "timed_connect" do
    it "waits the 'registration_timeout' before connecting" do
      s = Streamers::GetMyData.new
      s.register channel
      expect(s.restarted).to be_falsey
    end

    # Slows down the test suite, will need to figure out how to avoid this
    #
    # it "restarts the connection after the specified period" do
    #   s = Streamers::GetMyData.new
    #   s.register channel
    #   sleep 2
    #   expect(s.restarted).to be_truthy
    # end

  end

end
