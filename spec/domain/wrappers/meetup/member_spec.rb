require 'domain/wrappers/spec_helper'

RSpec.describe Wrappers::Meetup::Member, :type => :domain do

  let(:raw_rsvp) do
    raw_data(response_path: 'meetup/2_rsvps.json')['results'][0]
  end

  subject(:member) do
    Wrappers::Meetup::Member.new(raw_rsvp['member'], raw_rsvp['member_photo'])
  end

  describe "#id" do
    it "should respond with 'id' from raw data" do
      m = raw_rsvp['member']
      expect(member.id).to eq m['member_id'] || m['id']
    end
  end
  
  describe "#name" do
    it "should respond with 'name' from raw data" do
      m = raw_rsvp['member']
      expect(member.name).to eq m['member_name'] || m['name']
    end
  end

  describe "#thumb_link" do
    it "should respond with 'thumb_link' from raw data" do
      expect(member.thumb_link).to eq raw_rsvp['member_photo']['thumb_link']
    end
  end
end
