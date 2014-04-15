require 'domain/events/spec_helper'

describe Events::Facebook::Status do

  let(:raw_feed) do
    raw_data(response_path: 'facebook/feed.json')
  end

  let(:raw_status) do
    raw_feed.first{|x| x['type'] == 'status'}
  end

  let(:raw_video) do
    raw_feed.first{|x| x['type'] == 'video'}
  end

  let(:raw_photo) do
    raw_feed.first{|x| x['type'] == 'photo'}
  end

  let(:raw_link) do
    raw_feed.first{|x| x['type'] == 'link'}
  end

  describe "#digest_seed" do
    it "should respond with seed contained of id and class name" do
      seed =  raw_status['id']
      seed += "Events::Facebook::Status"

      status = Events::Facebook::Status.new(raw_status)
      expect(status.digest_seed).to eq seed
    end
  end
end
