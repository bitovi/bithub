require 'spec_helper'
#require 'services/crawler/streamers/all'
require 'services/crawler/streamer/registrable'


describe Streamers::Registrable do

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

  before { Celluloid.boot }
  after { Celluloid.shutdown }

  let(:channel) do
    channel = double()
    channel.stub(:name) { "nikica" }
    channel.stub(:topics) { %w(canjs jquery) }
    channel
  end

  let(:channel2) do
    channel = double()
    channel.stub(:name) { "veljko" }
    channel.stub(:topics) { %w(javascriptmvc what) }
    channel
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

    it "restarts the connection after the specified period" do
      s = Streamers::GetMyData.new
      s.register channel
      sleep 2
      expect(s.restarted).to be_truthy
    end

  end

end
