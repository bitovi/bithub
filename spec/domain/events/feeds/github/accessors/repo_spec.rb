require 'domain/events/spec_helper'

describe Events::Github::Accessors::Issue do

  let(:raw_repo) do
    raw_data(response_path: 'github/events/issue_comment_event.json')['repo']
  end

  subject(:repo) do
    Events::Github::Accessors::Repo.new(raw_repo)
  end
  
  # describe "#raw" do
  #   it "it should respond with raw data it was constructed with" do
  #     expect(repo.raw).to eq raw_repo.symbolize_keys
  #   end
  # end
  
  describe "#name" do
    it "should respond with 'name' from raw data" do
      expect(repo.name).to eq raw_repo['name']
    end
  end

end

