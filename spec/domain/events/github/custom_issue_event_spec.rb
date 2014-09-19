require 'domain/events/spec_helper'

describe Events::Github::CustomIssueEvent do

  let(:raw_custom_issue) do
    raw_data(response_path: 'github/issues/issues.json').first
  end
  
  subject(:custom_issue_event) do
    Events::Github::CustomIssueEvent.new(raw_custom_issue).wrap_response
  end

  describe "#content_digest" do
    it "should respond with seed consisted of :issue_id, :title, :body, :labels, :state and :updated_at" do
      seed =  raw_custom_issue['id'].to_s
      seed += raw_custom_issue['title']
      seed += raw_custom_issue['body']
      seed += raw_custom_issue['labels'].map{|l| l['name']}.join(',')
      seed += raw_custom_issue['state']
      seed += Time.parse(raw_custom_issue['updated_at']).utc.to_s
      seed += "Events::Github::CustomIssueEvent"

      expect(custom_issue_event.digest_seed).to eq seed
    end
  end

  describe "#repo_name" do
    it "should find the repo_name in url and pluck it out" do
      expect(custom_issue_event.repo_name).to eq raw_custom_issue['url'].match(/repos\/(.*)\/issues/).andand[1]
    end
  end
  
end
