require 'domain/events/spec_helper'

describe Events::Meetup::Rsvp do

  let(:raw_rsvp) do
    raw_data(response_path: 'meetup/2_rsvps.json')['results'].first
  end
  
  subject(:rsvp_event) do
    Events::Meetup::Rsvp.new(raw_rsvp)
  end

  describe "#digest_seed" do
    it "should calculate the digest using 'post_id' and class name" do
      seed = raw_rsvp['rsvp_id'].to_s + "Events::Meetup::Rsvp"
      expect(rsvp_event.digest_seed).to eq seed
    end
  end

  describe "#origin_id" do
    it "should delegate to @rsvp->#id" do
      expect(rsvp_event.origin_id).to eq rsvp_wrapper.id
    end
  end

  describe "#event_id" do
    it "should delegate to@event->#id" do
      expect(rsvp_event.event_id).to eq event_wrapper.id
    end
  end
  
  describe "#origin_author_id" do
    it "should be alias to a delegate method @member->#id" do
      expect(rsvp_event.origin_author_id).to eq member_wrapper.id
    end
  end

  describe "#origin_timestamp" do
    it "should be in UTC" do
      expect(rsvp_event.origin_timestamp.zone).to eq "UTC"
    end
  end
  
  # --- Delegates
  subject(:rsvp_wrapper) do
    Events::Meetup::Rsvp.new(raw_rsvp)
  end
  
  subject(:event_wrapper) do
    Wrappers::Meetup::Event.new(raw_rsvp['event'])
  end
  
  subject(:member_wrapper) do
    Wrappers::Meetup::Member.new(raw_rsvp['member'], raw_rsvp['member_photo'])
  end

end
