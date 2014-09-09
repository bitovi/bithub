require 'domain/events/spec_helper'

describe Events::Github::DeleteEvent do

  let(:raw_delete) do
    raw_data(response_path: 'github/events/delete_event.json')
  end

  subject(:delete) do
    Events::Github::DeleteEvent.new(raw_delete).wrap_response
  end
  
  describe "#digest_seed" do
    it "should respond with seed contained of actor_login, repo_name, ref_type, ref and class name" do
      seed =  raw_delete['actor']['login']
      seed += raw_delete['repo']['name']
      seed += raw_delete['payload']['ref_type']
      seed += raw_delete['payload']['ref'].to_s
      seed += "Events::Github::DeleteEvent"

      expect(delete.digest_seed).to eq seed
    end
  end

end
