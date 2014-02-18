require 'domain/events/spec_helper'

describe Events::Github::Delete do

  let(:raw_delete) do
    raw_data(response_path: 'github/events/delete_event.json')
  end

  subject(:delete) do
    Events::Github::Delete.new(raw_delete)
  end
  
  describe "#content_digest" do
    it "should calculate the content_diget by using actor_login, repo_name, ref_type, ref and class name"
  end

end
