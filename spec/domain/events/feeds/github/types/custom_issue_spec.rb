require 'domain/events/spec_helper'

describe Events::Github::CustomIssue do

  let(:raw_custom_issue) do
    raw_data(response_path: 'github/issues/issues.json').first
  end

  subject(:custom_issue) do
    Events::Github::CustomIssue.new(raw_custom_issue)
  end

  describe "#content_digest" do
    it "should respond with seed consisted of :issue_id, :title, :body, :labels, :state and :updated_at" do
      seed =  raw_custom_issue['id'].to_s
      seed += raw_custom_issue['title']
      seed += raw_custom_issue['body']
      seed += raw_custom_issue['labels'].map{|l| l['name']}.join(',')
      seed += raw_custom_issue['state']
      seed += raw_custom_issue['updated_at']

      expect(custom_issue.digest_seed).to eq seed
    end
  end

  describe "#title" do
    it "should respond with 'title' from raw_response"
  end

  describe "#body" do
    it "should respond with 'body' from raw_response"
  end

  describe "#html_url" do
    it "should respond with 'html_url' from raw_response"
  end

  describe "#labels" do
    it "should respond with 'labels' array from raw_response"
  end

  describe "#label_names" do
    it "should get only labels names as CSV"
  end

  describe "#state" do
    it "should respond with 'state' from raw_response"
  end

  describe "#number" do
    it "should respond with 'number' from raw_response"
  end

  describe "#user" do
    it "should respond with 'user' object from raw_response"
  end

  describe "#user_id" do
    it "should respond with 'user'->'id' from raw_response"
  end

  describe "#user_login" do
    it "should respond with 'user'->'login' from raw_response"
  end

  describe "#user_avatar_url" do
    it "should respond with 'user'->'avatar_url' from raw_response"
  end
  
  describe "#repo_name" do
    it "should find the repo_name in url and pluck it out"
  end
  
  describe "#referenced_issue_numbers" do
    it "should find the referenced issues in body"
  end
  
  describe "#referenced_issue_numbers_csv" do
    it "should respond with referenced issues as CSV"
  end

end
