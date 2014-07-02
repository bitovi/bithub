require 'domain/wrappers/spec_helper'

RSpec.describe Wrappers::Github::Issue, :type => :domain do

  let(:raw_repo) do
    raw_data(response_path: 'github/events/issue_comment_event.json')['repo']
  end

  subject(:repo) do
    Wrappers::Github::Repo.new(raw_repo)
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
  
  describe "#url" do
    it "should respond with 'url' from raw data" do
      expect(repo.url).to eq raw_repo['url']
    end
  end

end

