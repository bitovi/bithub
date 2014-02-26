require 'domain/wrappers/spec_helper'

describe Wrappers::Github::Comment do

  let(:raw_comment) do
    raw_data(response_path: 'github/events/issue_comment_event.json')['payload']['comment']
  end

  subject(:comment) do
    Wrappers::Github::Comment.new(raw_comment)
  end
  
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
  
  describe "#created_at" do
    it "is in UTC" do
      expect(comment.created_at.zone).to eq "UTC"
    end

    it "pharses the 'created_at' unix ts from raw response" do
      parsed = Time.parse(raw_comment['created_at'])
      expect(comment.created_at).to eq parsed
    end
  end
  
  describe "#updated_at" do
    it "is in UTC" do
      expect(comment.updated_at.zone).to eq "UTC"
    end

    it "parses the 'updated_at' unix ts from raw response" do
      parsed = Time.parse(raw_comment['updated_at'])
      expect(comment.updated_at).to eq parsed
    end
  end

end
