require 'domain/wrappers/spec_helper'

describe Wrappers::Github::Comment do

  let(:raw_comment) do
    raw_data(response_path: 'github/events/issue_comment_event.json')['payload']['comment']
  end

  subject(:comment) do
    Wrappers::Github::Comment.new(raw_comment)
  end
  
  # describe "#raw" do
  #   it "it should respond with raw data it was constructed with" do
  #     expect(comment.raw).to eq raw_comment.symbolize_keys
  #   end
  # end

  describe "#id" do
    it "should respond with 'id' from raw data" do
      expect(comment.id).to eq raw_comment['id']
    end
  end
  
  describe "#body" do
    it "should respond with 'body' from raw data" do
      expect(comment.body).to eq raw_comment['body']
    end
  end
  
  describe "#html_url" do
    it "should respond with 'html_url' from raw data" do
      expect(comment.html_url).to eq raw_comment['html_url']
    end
  end

  describe "#commit_id" do
    it "should respond with 'commit_id' from raw data" do
      expect(comment.commit_id).to eq raw_comment['commit_id']
    end
  end

end
