require 'domain/events/spec_helper'

describe Events::Meetup::Rsvp do

  let(:raw_rsvp) do
    raw_data(response_path: 'meetup/2_rsvps.json')['results'].first
  end
  
  subject(:rsvp) do
    Events::Meetup::Rsvp.new(raw_rsvp)
  end

  describe "#content_digest" do
    it "should calculate the digest using 'post_id' and class name" do
      digest = Digest::MD5.hexdigest(raw_rsvp['rsvp_id'].to_s + rsvp.class.name)
      expect(rsvp.content_digest).to eq digest
    end
  end

  describe "#origin_id" do
    it "should delegate to #rsvp_id" do
      expect(rsvp.origin_id).to eq rsvp.rsvp_id
    end
  end

  describe "#rsvp_id" do
    it "should respond with 'rsvp_id' from raw response" do
      expect(rsvp.rsvp_id).to eq raw_rsvp['rsvp_id']
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

  describe "#origin_author_id" do
    it "should delegate to #member_id" do
      expect(rsvp.origin_author_id).to eq rsvp.member_id
    end
  end

  describe "#member_id" do
    it "should respond with 'member_id' from raw response" do
      expect(rsvp.member_id).to eq raw_rsvp['member']['member_id']
    end
  end

  describe "#origin_author_name" do
    it "should delegate to #member_name" do
      expect(rsvp.origin_author_name).to eq rsvp.member_name
    end
  end

  describe "#member_name" do
    it "should respond with 'member'->'name'" do
      expect(rsvp.member_name).to eq raw_rsvp['member']['name']
    end
  end

  describe "#origin_author_avatar_url" do
    it "should delegate to member_photo_thumb_link" do
      expect(rsvp.origin_author_avatar_url).to eq rsvp.member_photo_thumb_link
    end
  end

  describe "#member_photo_thumb_link" do
    it "should respond with 'member_photo'->'thumb_link' from raw response" do
      expect(rsvp.member_photo_thumb_link).to eq raw_rsvp['member_photo']['thumb_link']
    end
  end

  describe "#parent_event_id" do
    it "should respond with 'event'->'id' from raw response" do
      expect(rsvp.parent_event_id).to eq raw_rsvp['event']['id']
    end
  end

  describe "#origin_timestamp" do
    it "should be in UTC" do
      expect(rsvp.origin_timestamp.zone).to eq "UTC"
    end

    it "should parse the 'created' unix timestamp from raw response and return it" do
      parsed_date = Time.at(raw_rsvp['created'].to_i / 1000)
      expect(rsvp.origin_timestamp).to eq parsed_date
    end
  end
end
