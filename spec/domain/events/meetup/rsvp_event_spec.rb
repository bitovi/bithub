require 'domain/events/spec_helper'

describe Events::Meetup::RsvpEvent do

  let(:raw_rsvp) do
    raw_data(response_path: 'meetup/2_rsvps.json')['results'].first
  end
  
  subject(:rsvp_event) do
    Events::Meetup::RsvpEvent.new(raw_rsvp)
  end

  describe "#digest_seed" do
    it "should calculate the digest using 'post_id' and class name" do
      seed = raw_rsvp['rsvp_id'].to_s + "Events::Meetup::RsvpEvent"
      expect(rsvp_event.digest_seed).to eq seed
    end
  end


end
