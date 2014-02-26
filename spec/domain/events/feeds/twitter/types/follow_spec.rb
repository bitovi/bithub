require 'domain/events/spec_helper'

describe Events::Twitter::Follow do

  let(:raw_follow) do
    raw_data(response_path: 'twitter/follow_event.json')
  end

  subject(:follow) do
    Events::Twitter::Follow.new(raw_follow)
  end

  describe "#content_digest" do
    it "should calculate the content_digest based on source_id, target_id and class name" do
      seed =  raw_follow['source']['id'].to_s
      seed += raw_follow['target']['id'].to_s
      seed += "Events::Twitter::Follow"
      expect(follow.digest_seed).to eq seed
    end
  end
end
