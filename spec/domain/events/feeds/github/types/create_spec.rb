require 'domain/events/spec_helper'

describe Events::Github::Create do

  let(:raw_create) do
    raw_data(response_path: 'github/events/create_event.json')
  end

  subject(:create) do
    Events::Github::Create.new(raw_create).wrap_response
  end
  
  describe "#digest_seed" do
    it "should respond with seed contained of actor_login, repo_name, ref_type, ref and class name" do
      seed =  raw_create['actor']['login']
      seed += raw_create['repo']['name']
      seed += raw_create['payload']['ref_type']
      seed += raw_create['payload']['ref']
      seed += "Events::Github::Create"

      expect(create.digest_seed).to eq seed
    end
  end

end
