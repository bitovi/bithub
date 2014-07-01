require 'domain/spec_helper'

RSpec.describe Wrappers::Github::Commit, :type => :domain do

  let(:raw_commit) do
    raw_data(response_path: 'github/events/push_event.json')['payload']['commits'].first
  end

  subject(:commit) do
    Wrappers::Github::Commit.new(raw_commit)
  end

  describe "#sha" do
    it "should respond with 'sha' from raw data" do
      expect(commit.sha).to eq raw_commit['sha']
    end
  end
  
  describe "#url" do
    it "should respond with 'url' from raw data" do
      expect(commit.url).to eq raw_commit['url']
    end
  end
  
  describe "#author_name" do
    it "should respond with 'author'->'name' from raw data" do
      expect(commit.author_name).to eq raw_commit['author']['name']
    end
  end
  
  describe "#author_email" do
    it "should respond with 'author'->'email' from raw data" do
      expect(commit.author_email).to eq raw_commit['author']['email']
    end
  end

end
