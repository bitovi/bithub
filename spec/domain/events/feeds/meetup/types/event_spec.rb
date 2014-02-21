require 'domain/events/spec_helper'

describe Events::Meetup::Event do

  let(:raw_event) do
    raw_data(response_path: 'meetup/2_events.json')['results'].first
  end
  
  subject(:event) do
    Events::Meetup::Event.new(raw_event)
  end

  describe "#digest_seed" do
    it "should construct the seed using (event_id, url, name, description, status, composite_location, latitude, longitude, event_host_ids_csv)" do
      seed =  raw_event['id']
      seed += raw_event['event_url']
      seed += raw_event['name']
      seed += raw_event['description']
      seed += raw_event['status']
      # seed += raw_event['venue']
      seed += raw_event['venue']['lat'].to_s
      seed += raw_event['venue']['lon'].to_s
      seed += "Event::Meetup::Event"

      expect(event.digest_seed).to eq seed
    end
  end
  
  describe "#origin_id" do
    it "should delegate to #url" do
      expect(event.origin_id).to eq event.url
    end
  end

  describe "#event_id" do
    it "should respond with 'id' from raw response" do
      expect(event.event_id).to eq raw_event['id']
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
    it "should be in UTC" do
      expect(event.time.zone).to eq "UTC"
    end

    it "should parse the 'time' unix timestamp from raw response" do
      parsed = Time.at(raw_event.andand['time'].to_i / 1000).utc
      expect(event.time).to eq parsed
    end
  end

  describe "#scheduled_at" do
    it "return the scheduled at 'time' in ISO8601 format" do
      expect(event.scheduled_at).to eq event.time.iso8601
    end
  end

  describe "#origin_timestamp" do
    it "should be in UTC" do
      expect(event.origin_timestamp.zone).to eq "UTC"
    end

    it "should parse the 'created' unix timestamp from raw response" do
      parsed = Time.at(raw_event.andand['created'].to_i / 1000).utc
      expect(event.origin_timestamp).to eq parsed
    end
  end

  describe "#event_host_ids_csv" do
    pending "add some tests"
  end

end
