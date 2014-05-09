require 'no_rails_spec_helper'
require 'services/crawler/streamers/all'
require 'services/crawler/streamers/registrable'


describe Streamers::Registrable do

  module Streamers
    class GetMyData
      include Registrable

      def connect; end
      def reconnect; end
    end
  end

  let(:channel) do
    channel = double()
    channel.stub(:name) { "nikica" }
    channel.stub(:topics) { %w(canjs jquery) }
    channel
  end

  describe "#register" do
    it "adds the channel to list of subscribers" do
      s = Streamers::GetMyData.new
      s.register(channel)
      expect(s.channels).to include(channel)
    end
  end

  describe "#unregister" do
    it "removes the channel from the list of subscribers" do
      s = Streamers::GetMyData.new
      s.register(channel)
      expect{ s.unregister(channel.name) }.to change{ s.channels }.from([channel]).to([])
    end
  end

end
