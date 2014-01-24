require 'domain/entities/spec_helper'

#require_relative 'github_issue_spec'
#require_relative 'github_push_spec'

# Helpers functions for mocking payloads

def build_standard_github_payload(name, attrs={})
  payload = double(name)
  payload.stub(:feed => "github")
  payload.stub(:repo_name => "bitovi/canjs")
  payload.stub(:origin_ts => Time.now)
  payload.stub(:referenced_issue_numbers => attrs[:referenced_issue_numbers] || [])
  payload.stub(:switch_to_camel_case => lambda {})
  payload
end

def build_issue(attrs={})
  payload = build_standard_github_payload('Events::Github::Issue', attrs)
  payload.stub(:type => "issue")
  payload.stub(:title => "Having issue with something on ...")    
  payload.stub(:body => attrs[:body] || "Long description of an issue with examples ...")
  payload.stub(:html_url => "http://github.com/issues/123")
  payload.stub(:number => attrs[:number] || "123")
  payload.stub(:number => attrs[:number] || "123")
  payload.stub(:issue_id => attrs[:issue_id] || "123456")
  payload.stub(:label_names => "")
  payload.stub(:state => "open")
  Entities::Github::Issue.new(payload).procure
end

def build_issue_comment(attrs={})
  payload = build_standard_github_payload('Events::Github::IssueComment', attrs)
  payload.stub(:type => "issue_comment")
  payload.stub(:body => attrs[:body] || "Commenting an issue with something wise ...")
  payload.stub(:html_url => "http://github.com/issue/123#issuecomment-123456")
  payload.stub(:number => attrs[:number] || "123")
  payload.stub(:number => attrs[:number] || "123")
  payload.stub(:label_names => "")
  payload.stub(:comment_id => attrs[:comment_id] || "123456")
  Entities::Github::IssueComment.new(payload).procure
end

def build_commit_comment(attrs={})
  payload = build_standard_github_payload('Events::Github::CommitComment', attrs)
  payload.stub(:type => "commit_comment")
  payload.stub(:body => attrs[:body] || "Lorem ipsum ...")
  payload.stub(:html_url => "http://github.com/foobar")
  payload.stub(:commit_id => attrs[:comment_id] || "12345")
  Entities::Github::CommitComment.new(payload).procure
end

def build_pull_req(attrs={})  
  payload = build_standard_github_payload('Events::Github::PullRequest', attrs)
  payload.stub(:type => "pull_request")
  payload.stub(:body => attrs[:body] || "Lorem ipsum")
  payload.stub(:html_url => "http://github.com/foobar")
  payload.stub(:number => attrs[:number] || "123")
  payload.stub(:number => attrs[:number] || "123")
  payload.stub(:pull_request_id => "456")
  payload.stub(:state => "open")
  payload.stub(:action => "open")
  Entities::Github::PullRequest.new(payload).procure
end

def build_pull_req_comment(attrs={})
  payload = build_standard_github_payload('Events::Github::PullRequestComment', attrs)
  payload.stub(:type => "pull_request_comment")
  Entities::Github::PullRequestComment.new(payload).procure
end

def build_push(attrs={})
  commits = [
    {sha: '12345', message:'first, with ref to #100 and #200 ...'},
    {sha: '67890', message:'second, with ref to #100'}
  ]
  
  payload = build_standard_github_payload('Events::Github::Push', attrs)
  payload.stub(:type => "push") # push_event
  payload.stub(:head => "12345")
  payload.stub(:push_id => "12345")
  payload.stub(:commit_shas => ["12345","67890"])
  payload.stub(:commit_shas_csv => "12345,67890")
  payload.stub(:referenced_issue_numbers => ["100","200"])
  payload.stub(:commit_by_sha) do |sha|
    commits.select {|c| c[:sha] == sha}.first
  end
  payload.stub(:commits => attrs[:commits] || commits)
  Entities::Github::Push.new(payload).procure
end
