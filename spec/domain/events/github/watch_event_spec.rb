require 'domain/events/spec_helper'

describe Events::Github::WatchEvent do

  let(:raw_watch) do
    raw_data(response_path: 'github/events/watch_event.json')
  end

  subject(:watch) do
    Events::Github::WatchEvent.new(raw_watch).wrap_response
  end
  
  describe "#digest_seed" do
    it "should construct the digest seed from actor id, repo name and class name" do
      seed =  raw_watch['actor']['id'].to_s
      seed += raw_watch['repo']['name']
      seed += "Events::Github::WatchEvent"
      expect(watch.digest_seed).to eq seed
    end
  end

end
