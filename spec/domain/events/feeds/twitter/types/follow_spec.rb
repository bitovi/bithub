require 'domain/events/spec_helper'

describe Events::Twitter::Follow do

  let(:raw_follow) do
    raw_data(response_path: 'twitter/follow_event.json')
  end

  subject(:follow) do
    Events::Twitter::Follow.new(raw_follow)
  end

  describe "#content_digest" do
    it "should calculate the content_digest based on source_id, target_id and class name" do
      digest = Digest::MD5.hexdigest(raw_follow['source']['id_str'] + raw_follow['target']['id_str'] + follow.class.name)
      expect(follow.content_digest).to eq digest
    end
  end

  describe "#source_id" do
    it "should respond_with 'source'->'id' from raw response" do
      expect(follow.source_id).to eq raw_follow['source']['id']
    end
  end

  describe "#source_screen_name" do
    it "should respond_with 'source'->'name' from raw response" do
      expect(follow.source_screen_name).to eq raw_follow['source']['screen_name']
    end
  end

  describe "#target_id" do
    it "should respond_with 'target'->'id' from raw response" do
      expect(follow.target_id).to eq raw_follow['target']['id']
    end
  end

  describe "#target_screen_name" do
    it "should respond_with 'target'->'name' from raw response" do
      expect(follow.target_screen_name).to eq raw_follow['target']['screen_name']
    end
  end

  describe "#origin_timestamp" do
    it "should be in UTC" do
      expect(follow.origin_timestamp.zone).to eq "UTC"
    end

    it "should respond with time-parsed 'created_at' from raw response" do
      parsed_time = Time.parse(raw_follow.andand['created_at']).utc
      expect(follow.origin_timestamp).to eq parsed_time
    end
  end
    
end
