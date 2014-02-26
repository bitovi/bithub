require 'domain/wrappers/spec_helper'

describe Wrappers::Meetup::Rsvp do

  let(:raw_rsvp) do
    raw_data(response_path: 'meetup/2_rsvps.json')['results'].first
  end
  
  subject(:rsvp) do
    Wrappers::Meetup::Rsvp.new(raw_rsvp)
  end

  describe "#id" do
    it "responds with 'id' from raw response" do
      expect(rsvp.id).to eq raw_rsvp['rsvp_id']
    end
  end

  describe "#comment" do
    it "responds with 'comment' from raw response" do
      expect(rsvp.comment).to eq raw_rsvp['comment']
    end
  end

  describe "#response" do
    it "responds with 'response' from raw response" do
      expect(rsvp.response).to eq raw_rsvp['response']
    end
  end

  describe "#created_at" do
    it "parse the 'created' unix ts from raw response" do
      parsed = Time.at(raw_rsvp.andand['created'].to_i / 1000)
      expect(rsvp.created_at).to eq parsed
    end

    it "is in UTC" do
      expect(rsvp.created_at.zone).to eq "UTC"
    end
  end

end
