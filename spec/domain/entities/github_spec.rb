require 'domain/entities/spec_helper'

def build_standard_github_payload(attrs={})
  payload = double()
  payload.stub(:feed => "github")
  payload.stub(:repo_name => "bitovi/canjs")
  payload.stub(:origin_ts => Time.now)
  payload.stub(:switch_to_camel_case => lambda {})
  payload
end

def build_issue(attrs={})
  payload = build_standard_github_payload(attrs)
  payload.stub(:type => "issue")
  payload.stub(:title => "Having issue with something on ...")    
  payload.stub(:body => attrs[:body] || "Long description of an issue with examples ...")
  payload.stub(:html_url => "http://github.com/issues/123")
  payload.stub(:number => attrs[:number] || "123")
  payload.stub(:issue_or_pull_req_number => attrs[:number] || "123")
  payload.stub(:issue_id => attrs[:issue_id] || "123456")
  payload.stub(:label_names => "")
  payload.stub(:state => "open")
  Entities::Github::Issue.new(payload).procure
end

def build_issue_comment(attrs={})
  payload = build_standard_github_payload(attrs)
  payload.stub(:type => "issue_comment")
  payload.stub(:body => attrs[:body] || "Commenting an issue with something wise ...")
  payload.stub(:html_url => "http://github.com/issue/123#issuecomment-123456")
  payload.stub(:number => attrs[:number] || "123")
  payload.stub(:issue_or_pull_req_number => attrs[:number] || "123")
  payload.stub(:label_names => "")
  payload.stub(:comment_id => attrs[:comment_id] || "123456")
  Entities::Github::IssueComment.new(payload).procure
end

# def build_commit(attrs={})
#   payload = double()
#   Entities::Github::Commit.new(Entity, payload).procure  
# end

def build_commit_comment(attrs={})
  payload = build_standard_github_payload(attrs)
  payload.stub(:type => "commit_comment")
  payload.stub(:body => attrs[:body] || "Lorem ipsum ...")
  payload.stub(:html_url => "http://github.com/foobar")
  payload.stub(:commit_id => attrs[:comment_id] || "12345")
  Entities::Github::CommitComment.new(payload).procure
end


def build_pull_req(attrs={})  
  payload = build_standard_github_payload(attrs)
  payload.stub(:type => "pull_request")
  payload.stub(:body => attrs[:body] || "Lorem ipsum")
  payload.stub(:html_url => "http://github.com/foobar")
  payload.stub(:number => attrs[:number] || "123")
  payload.stub(:issue_or_pull_req_number => attrs[:number] || "123")
  payload.stub(:pull_request_id => "456")
  payload.stub(:state => "open")
  payload.stub(:action => "open")
  Entities::Github::PullRequest.new(payload).procure
end

def build_pull_req_comment(attrs={})
  payload = build_standard_github_payload(attrs)
  payload.stub(:type => "pull_request_comment")
  Entities::Github::PullRequestComment.new(payload).procure
end

def build_push(attrs={})  
  payload = build_standard_github_payload(attrs)
  payload.stub(:type => "push") # push_event
  payload.stub(:head => "12345")
  payload.stub(:push_id => "12345")
  payload.stub(:commit_shas => ["12345","67890"])
  payload.stub(:commit_shas_csv => "12345,67890")
  payload.stub(:commits => [{sha: '12345', message:'first'},{sha: '67890', message:'second'}])
  Entities::Github::Push.new(payload).procure
end

def build_watch(attrs={})
  payload = build_standard_github_payload(attrs)
  payload.stub(:type => "watch")
  Entities::Github::Watch.new(payload).procure
end

issue_def = {number: "100", issue_id: "1001"}
issue_def2 = {number: "200", issue_id: "2001"}
issue_comment_def = {number: "100", comment_id: "1002"}
issue_comment_def2 = {number: "100", comment_id: "1003"}
push_def = {}
pull_req_def = {}
pull_req_comment_def = {}
commit_def = {}
commit_comment_def = {}
watch_def = {}

describe Entities::Github::Issue do  
  describe "#build" do
    it "instances new Entity object" do
      i = build_issue()
      i.determine
      i.persist!
      
      expect(i.instance.title).to be_a(String)
      expect(i.instance.body).to be_a(String)
      expect(i.instance.url).to be_a(String)
      expect(i.instance.props['repo_name']).to be_a(String)
      expect(i.instance.props['number']).not_to be_empty
      expect(i.instance.props['issue_id']).not_to be_empty
      expect(i.instance.props['label_names']).to be_a(String)
      expect(i.instance.props['state']).to be_a(String)
    end
  end

  describe "#procure_children" do
    it "checks for children" do
      ic = build_issue_comment(issue_comment_def); ic.determine; ic.persist!
      i = build_issue(issue_def); i.determine; i.persist!
      ic2 = build_issue_comment(issue_comment_def2); ic2.determine; ic2.persist!
      i2 = build_issue(issue_def2); i2.determine; i2.persist!

      expect(i.procure_children.length).to eq(2)
      expect(i2.procure_children.length).to eq(0)
    end
  end  
end

describe Entities::Github::IssueComment do
  describe "#build" do
    it "instances new Entity object" do
      ic = build_issue_comment(); ic.determine; ic.persist!
      
      expect(ic.instance.title).to be_a(String)
      expect(ic.instance.body).to be_a(String)
      expect(ic.instance.url).to be_a(String)
      expect(ic.instance.props['repo_name']).to be_a(String)
      expect(ic.instance.props['number']).not_to be_empty
      expect(ic.instance.props['comment_id']).not_to be_empty
    end
  end

  describe "#procure_parent" do
    it "checks for the parent issue" do
      ic = build_issue_comment(issue_comment_def); ic.determine; ic.persist!
      i = build_issue(issue_def); i.determine; i.persist!
      ic2 = build_issue_comment(issue_comment_def2); ic2.determine; ic2.persist!
      i2 = build_issue(issue_def2); i2.determine; i2.persist!

      expect(ic.procure_parent.id).to eq(i.instance.id)
      expect(ic2.procure_parent.id).to eq(i.instance.id)
    end
  end
end

describe Entities::Github::PullRequest do
  describe "#build" do
    it "instances new Entity object" do
      pr = build_pull_req(); pr.determine; pr.persist!

      expect(pr.instance.title).to be_a(String)
      expect(pr.instance.body).to be_a(String)
      expect(pr.instance.url).to be_a(String)          
      expect(pr.instance.props['repo_name']).to be_a(String)
      expect(pr.instance.props['number']).not_to be_empty
      expect(pr.instance.props['pull_request_id']).not_to be_empty
      expect(pr.instance.props['state']).to be_a(String)
      expect(pr.instance.props['action']).to be_a(String)
    end
  end  
end

# PullRequestComment behaves the same as IssueComment
# describe Entities::Github::PullRequestComment do
#   describe "#build" do
#     it "instances new Entity object"
#   end  
# end

describe Entities::Github::Push do
  describe "#build" do
    it "instances new Entity object" do
      p = build_push(); p.determine; p.persist!

      expect(p.instance.title).to be_a(String)
      expect(p.instance.url).to be_a(String)
      expect(p.instance.props['repo_name']).to be_a(String)
      expect(p.instance.props['commit_shas']).not_to be_empty
      expect(p.instance.props['push_id']).not_to be_empty
    end
  end  
end

# describe Entities::Github::Commit do
#   describe "#build" do
#     it "instances new Entity object"
#   end  
# end

describe Entities::Github::CommitComment do
  describe "#build" do
    it "instances new Entity object" do
      cc = build_commit_comment(); cc.determine; cc.persist!

      expect(cc.instance.title).to be_a(String)
      expect(cc.instance.body).to be_a(String)
      expect(cc.instance.url).to be_a(String)
      expect(cc.instance.props['repo_name']).to be_a(String)
      expect(cc.instance.props['commit_id']).not_to be_empty      
    end
  end
  
  # describe "#procure_parent" do
  #   it "checks for the parent commit"
  # end
end
