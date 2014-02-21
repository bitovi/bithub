require 'domain/events/spec_helper'

class IssueLikeClass
  include Events::Github::Accessors::IssueLike
  include CoreHelpers

  def initialize(data)
    @i = symbolize_keys(data)
  end
end

describe Events::Github::Accessors::IssueLike do

  let(:raw_issue) do
    raw_data(response_path: 'github/events/issues_event.json')['payload']['issue']
  end

  subject(:issue_like_object) do
    IssueLikeClass.new(raw_issue)
  end
  
  # describe "#raw" do
  #   it "it should respond with raw data it was constructed with" do
  #     expect(commit.raw).to eq raw_commit.symbolize_keys
  #   end
  # end

  describe "#title" do
    it "should respond with 'title' from raw data" do
      expect(issue_like_object.title).to eq raw_issue['title']
    end
  end
  
  describe "#body" do
    it "should respond with 'body' from raw data" do
      expect(issue_like_object.body).to eq raw_issue['body']
    end
  end
  
  describe "#html_url" do
    it "should respond with 'author'->'name' from raw data" do
      expect(issue_like_object.html_url).to eq raw_issue['html_url']
    end
  end
  
  describe "#number" do
    it "should respond with 'author'->'email' from raw data" do
      expect(issue_like_object.number).to eq raw_issue['number']
    end
  end
  
  describe "#state" do
    it "should respond with 'state' from raw data" do
      expect(issue_like_object.state).to eq raw_issue['state']
    end
  end
  
  describe "#action" do
    it "should respond with 'action' from raw data" do
      expect(issue_like_object.action).to eq raw_issue['action']
    end
  end

end
