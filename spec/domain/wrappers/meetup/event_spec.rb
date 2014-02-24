require 'domain/wrappers/spec_helper'

describe Wrappers::Meetup::Event do

  let(:raw_event) do
    raw_data(response_path: 'meetup/2_events.json')['results'].first
  end
  
  subject(:event) do
    Wrappers::Meetup::Event.new(raw_event)
  end

  describe "#id" do
    it "should respond with 'id' from raw response" do
      expect(event.id).to eq raw_event['id']
    end
  end

  describe "#name" do
    it "should respond with 'name' from raw response" do
      expect(event.name).to eq raw_event['name']
    end
  end

  describe "#description" do
    it "should respond with 'description' from raw response" do
      expect(event.description).to eq raw_event['description']
    end
  end

  describe "#url" do
    it "should respond with 'event_url' from raw response" do
      expect(event.url).to eq raw_event['event_url']
    end
  end

  describe "#status" do
    it "should respond with 'status' from raw response" do
      expect(event.status).to eq raw_event['status']
    end
  end

  describe "#time" do
    it "should parse the 'time' unix timestamp from raw response" do
      parsed = Time.at(raw_event.andand['time'].to_i / 1000)
      expect(event.time).to eq parsed
    end
  end

  describe "#created" do
    it "should parse the 'created' unix createdstamp from raw response" do
      parsed = Time.at(raw_event.andand['created'].to_i / 1000)
      expect(event.created).to eq parsed
    end
  end
  
  describe "#host_ids" do
    it "should respond with an array of ids of hosts" do
      expect(event.host_ids).to eq raw_event['event_hosts'].map{|h| h['member_id']}
    end
  end

  describe "#host_names" do
    it "should respond with an array of names of hosts" do
      expect(event.host_names).to eq raw_event['event_hosts'].map{|h| h['member_name']}
    end
  end
    
end
