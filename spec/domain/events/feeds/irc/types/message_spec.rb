require 'domain/events/spec_helper'

describe Events::Irc::Message do

  let(:current_time) { Time.now.utc }

  let(:raw_message) do
    {
      channel: '#canjs',
      nickname: 'veljko',
      message: 'foobar',
      ts: current_time
    }
  end
  
  subject(:message) do
    Events::Irc::Message.new(raw_message)
  end

  describe "#digest_seed" do
    it "should calculate the digest using 'channel', 'nickname' and 'origin_ts'" do
      seed = raw_message[:channel] + raw_message[:nickname]  + raw_message[:message] + raw_message[:ts].to_s + message.class.name
      expect(message.digest_seed).to eq seed
    end
  end

  describe "#message" do
    it "should respond with 'message' from raw data" do
      expect(message.message).to eq raw_message[:message]
    end
  end

  describe "#url" do
    it "should construct the url from the channel name and a fixed freenode address prefix" do
      expect(message.url).to eq "http://webchat.freenode.net/?channels=#{raw_message[:channel]}"
    end
  end

  describe "#nickname" do
    it "should respond with 'nickname' from raw data" do
      expect(message.nickname).to eq raw_message[:nickname]
    end
  end

  describe "#origin_ts" do
    it "should respond with 'ts' from raw_data" do
      expect(message.origin_ts).to eq current_time
    end

    it "should be in UTC" do
      expect(message.origin_ts.zone).to eq "UTC"
    end
  end

end
