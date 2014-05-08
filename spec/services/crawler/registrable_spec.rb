require 'no_rails_spec_helper'
require 'services/crawler/streamers/all'
require 'services/crawler/streamers/registrable'

module Streamers
  class GetMyData
    include Registrable

    def connect; end
    def reconnect; end
  end
end

describe Streamers::Registrable do
  Channel = Struct.new(:name, :topics)

  let(:channel) do
    Channel.new
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

  describe "#route" do
    it "routes the message to the appropriate channel" do
    end
  end
end
