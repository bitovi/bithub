require 'domain/events/spec_helper'

describe Events::Github::CustomIssue do

  let(:raw_custom_issue) do
    raw_data(response_path: 'github/issues/issues.json').first
  end
  
  subject(:custom_issue_wrapper) do
    Wrappers::Github::Issue.new(raw_custom_issue)
  end

  subject(:custom_issue_event) do
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
      seed += "Events::Github::CustomIssue"

      expect(custom_issue_event.digest_seed).to eq seed
    end
  end

  describe "#origin_id" do
    it "should delegate to @post->#id" do
      expect(custom_issue_event.origin_id).to eq custom_issue_wrapper.id
    end
  end
  
  describe "#repo_name" do
    it "should find the repo_name in url and pluck it out" do
      expect(custom_issue_event.repo_name).to eq raw_custom_issue['url'].match(/repos\/(.*)\/issues/).andand[1]
    end
  end
  
end
