push_def = {}
commit_def = {}
commit_comment_def = {}

describe Entities::Github::Push do
  describe "#build" do
    it "instances new Github Push entity " do
      p = build_push(); p.determine.group.normalize.persist!

      # check push
      expect(p.instance.title).to be_a(String)
      expect(p.instance.url).to be_a(String)
      expect(p.instance.props['repo_name']).to be_a(String)
      expect(p.instance.props['commit_shas']).not_to be_empty
      expect(p.instance.props['push_id']).not_to be_empty

      # procure commits
      expect(Entity.where(:parent_id => p.instance.id).count).to eq(2)
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
