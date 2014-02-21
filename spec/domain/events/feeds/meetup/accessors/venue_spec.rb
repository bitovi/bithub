require 'domain/events/spec_helper'

describe Events::Meetup::Accessors::Venue do

  let(:raw_venue) do
    raw_data(response_path: 'meetup/2_events.json')['results'].first['venue']
  end
  
  subject(:venue) do
    Events::Meetup::Accessors::Venue.new(raw_venue)
  end

  describe "#name" do
    it "should respond with 'name' from raw resonse" do
      expect(venue.name).to eq raw_venue['name']
    end
  end

  describe "#country" do
    it "should construct the country name by upcasing the name if 'us', and capitalizing otherwise" do
      expect(venue.country).to eq ((c = raw_venue['country']) == 'us') ? c.upcase : c.capitalize
    end
  end

  describe "#address" do
    it "should construct the address by joining address lines" do
      expect(venue.address).to eq (1..3).map {|n| raw_venue["address_#{n}"]}.compact.join(' ')
    end
    
  end

  describe "#city" do
    it "should construct the city name by joining 'city', 'state' and 'zip' attrs" do
      expect(venue.city).to eq [raw_venue['city'], raw_venue['state'], raw_venue['zip']].compact.join(' ')
    end
  end

  describe "#lat" do
    it "should get 'lat' from raw response" do
      expect(venue.lat).to eq raw_venue['lat'].to_s
    end
  end

  describe "#lon" do
    it "should get 'lon' from raw response" do
      expect(venue.lon).to eq raw_venue['lon'].to_s
    end
  end

end
