require 'domain/events/spec_helper'

describe Events::Github::Create do

  let(:raw_create) do
    raw_data(response_path: 'github/events/create_event.json')
  end

  subject(:create) do
    Events::Github::Create.new(raw_create)
  end
  
  describe "#content_digest" do
    it "should calculate the content_diget by using actor_login, repo_name, ref_type, ref and class name"
  end

end
