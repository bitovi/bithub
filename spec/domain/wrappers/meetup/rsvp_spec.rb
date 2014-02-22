require 'domain/wrappers/spec_helper'

describe Wrappers::Meetup::Rsvp do

  let(:raw_rsvp) do
    raw_data(response_path: 'meetup/2_rsvps.json')['results'].first
  end
  
  subject(:rsvp) do
    Wrappers::Meetup::Rsvp.new(raw_rsvp)
  end

  describe "#id" do
    it "should respond with 'id' from raw response" do
      expect(rsvp.id).to eq raw_rsvp['rsvp_id']
    end
  end

  describe "#comment" do
    it "should respond with 'comment' from raw response" do
      expect(rsvp.comment).to eq raw_rsvp['comment']
    end
  end

  describe "#response" do
    it "should respond with 'response' from raw response" do
      expect(rsvp.response).to eq raw_rsvp['response']
    end
  end

  describe "#created" do
    it "should parse the 'created' unix createdstamp from raw response" do
      parsed = Time.at(raw_rsvp.andand['created'].to_i / 1000)
      expect(rsvp.created).to eq parsed
    end
  end

end
