require 'domain/wrappers/spec_helper'

describe Wrappers::Meetup::Event do

  let(:raw_event) do
    raw_data(response_path: 'meetup/2_events.json')['results'].first
  end
  
  subject(:event) do
    Wrappers::Meetup::Event.new(raw_event)
  end

  describe "#id" do
    it "responds with 'id' from raw response" do
      expect(event.id).to eq raw_event['id']
    end
  end

  describe "#name" do
    it "responds with 'name' from raw response" do
      expect(event.name).to eq raw_event['name']
    end
  end

  describe "#description" do
    it "responds with 'description' from raw response" do
      expect(event.description).to eq raw_event['description']
    end
  end

  describe "#url" do
    it "responds with 'event_url' from raw response" do
      expect(event.url).to eq raw_event['event_url']
    end
  end

  describe "#status" do
    it "responds with 'status' from raw response" do
      expect(event.status).to eq raw_event['status']
    end
  end

  describe "#scheduled_at" do
    it "is in UTC" do
      expect(event.scheduled_at.zone).to eq "UTC"
    end

    it "parses the 'scheduled_at' unix ts from raw response" do
      parsed = Time.at(raw_event['time'].to_i / 1000)
      expect(event.scheduled_at).to eq parsed
    end
  end

  describe "#created_at" do
    it "is in UTC" do
      expect(event.created_at.zone).to eq "UTC"
    end

    it "parses the 'created_at' unix ts from raw response" do
      parsed = Time.at(raw_event['created'].to_i / 1000)
      expect(event.created_at).to eq parsed
    end
  end
  
  describe "#host_ids" do
    it "responds with an array of ids of hosts" do
      expect(event.host_ids).to eq raw_event['event_hosts'].map{|h| h['member_id']}
    end
  end

  describe "#host_names" do
    it "responds with an array of names of hosts" do
      expect(event.host_names).to eq raw_event['event_hosts'].map{|h| h['member_name']}
    end
  end
    
end
