issue_def = {number: "100", issue_id: "1001"}
issue_def2 = {number: "200", issue_id: "2001"}
issue_comment_def = {number: "100", comment_id: "1002"}
issue_comment_def2 = {number: "100", comment_id: "1003"}

describe Entities::Github::Issue do  
  describe "#build" do
    it "instances new Github Issue entity" do
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

  describe "#procure_references" do
    it "checks for entities contain references to exact issue"
  end  
end

describe Entities::Github::IssueComment do
  describe "#build" do
    it "instances new Github Issue Comment entity" do
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
    it "instances new Github Pull Request entity" do
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

