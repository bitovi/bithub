require 'domain/events/spec_helper'

describe Events::Github::Push do

  let(:raw_push) do
    raw_data(response_path: 'github/events/push_event.json')
  end

  subject(:push) do
    Events::Github::Push.new(raw_push)
  end

  describe "#digest_seed" do
    it "should respond with digest seed constructed of event_id" do
      expect(push.digest_seed).to eq raw_push['id'] + "Events::Github::Push"
    end
  end

  describe "#origin_id" do
    it "should delegate to @comment->#id" do
      expect(push.origin_id).to eq push.push_id
    end
  end

  describe "#push_id" do
    it "should respond with 'push_id' from raw response" do
      expect(push.push_id).to eq raw_push['payload']['push_id']
    end
  end

  describe "#head" do
    it "should respond with 'head' from raw response" do
      expect(push.head).to eq raw_push['payload']['head']
    end
  end

  describe "#commit_shas" do
    it "should respond with an array of commit shas from raw response" do
      expect(push.commit_shas).to eq raw_push['payload']['commits'].map{|el| el['sha']}
    end
  end
  
  describe "#commit_messages" do
    it "should respond with an array of commit shas from raw response" do
      expect(push.commit_messages).to eq raw_push['payload']['commits'].map{|el| el['message']}
    end
  end

  describe "#commit_by_sha" do
    it "should respond with a Commit wrapper object that matches the provides SHA" do
      sha = raw_push['payload']['commits'].first['sha']
      expect(push.commit_by_sha(sha)).to eq Wrappers::Github::Commit.new(raw_push['payload']['commits'].first)
    end
    
  end

end
