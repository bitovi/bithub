require 'domain/events/spec_helper'

describe Events::Github::Accessors::Issue do

  let(:raw_issue) do
    raw_data(response_path: 'github/events/issue_comment_event.json')['payload']['issue']
  end

  subject(:issue) do
    Events::Github::Accessors::Issue.new(raw_issue)
  end
  
  # describe "#raw" do
  #   it "it should respond with raw data it was constructed with" do
  #     expect(issue.raw).to eq raw_issue.symbolize_keys
  #   end
  # end

end
