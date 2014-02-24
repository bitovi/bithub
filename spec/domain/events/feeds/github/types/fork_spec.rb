require 'domain/events/spec_helper'

describe Events::Github::Fork do

  let(:raw_fork) do
    raw_data(response_path: 'github/events/fork_event.json')
  end

  subject(:fork) do
    Events::Github::Fork.new(raw_fork)
  end

  describe "#digest_seed" do
    it "should respond with seed constructed from @actor->#login, @repo->#name and class name" do
      seed =  raw_fork['actor']['login']
      seed += raw_fork['repo']['name']
      seed += "Events::Github::Fork"
      expect(fork.digest_seed).to eq seed
    end
  end

end
