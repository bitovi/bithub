require 'domain/wrappers/spec_helper'

describe Wrappers::Facebook::Status do

  let(:raw_status) do
    raw_data(response_path: 'facebook/feed.json').first
  end

  subject(:status) do
    Wrappers::Facebook::Status.new(raw_status)
  end
  
  describe "#id" do
    it "should respond with 'id' from raw data" do
      expect(status.id).to eq raw_status['id']
    end
  end
  
  describe "#message" do
    it "should respond with 'body' from raw data" do
      expect(status.message).to eq raw_status['message']
    end
  end
  
  describe "#link" do
    it "should respond with 'html_url' from raw data" do
      expect(status.link).to eq raw_status['link']
    end
  end

  describe "#created_time" do
    it "is in UTC" do
      expect(status.created_time.zone).to eq "UTC"
    end

    it "parses the 'created_time'" do
      parsed = Time.parse(raw_status['created_time'])
      expect(status.created_time).to eq parsed
    end
  end
  
  describe "#updated_time" do
    it "is in UTC" do
      expect(status.updated_time.zone).to eq "UTC"
    end

    it "parses the 'updated_at' unix ts from raw response" do
      parsed = Time.parse(raw_status['updated_time'])
      expect(status.updated_time).to eq parsed
    end
  end

end
