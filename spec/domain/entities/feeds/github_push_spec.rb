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
      expect(p.instance.props['origin_id']).not_to be_empty

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
      cc = build_commit_comment(); cc.determine.normalize.persist!

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

    # describe ".prepare_commit" do
    #   it "should assign the 'custom_commit_event' as :type to new commits" do
    #     push = build(:github_push, :with_push_event_source_data, props: { type: "push_event", feed: "github", commits: "3sdaf4s,43a2aa8,295aa54" })
    #     prepared_event = Event.prepare_commit(push.source_data[:payload][:commits].first, push)

    #     expect(prepared_event[1][:type]).to eq('custom_commit_event')
    #   end
      
    #   it "should assign the commit SHA as the hash_key attribute to new commits" do
    #     push = build(:github_push, :with_push_event_source_data, props: { type: "push_event", feed: "github", commits: "3sdaf4s,43a2aa8,295aa54" })
    #     prepared_event = Event.prepare_commit(push.source_data[:payload][:commits].first, push)
    #     expect(prepared_event[0][:hash_key]).to eq(push.source_data[:payload][:commits][0][:sha])
    #   end

    #   it "should assign timestamps to new commits" do
    #     push = build(:github_push, :with_push_event_source_data, props: { type: "push_event", feed: "github", commits: "3sdaf4s,43a2aa8,295aa54" })
    #     prepared_event = Event.prepare_commit(push.source_data[:payload][:commits].first, push)
    #     expect(prepared_event[0][:origin_ts]).to be
    #   end
    # end

# def original_args
#   ActiveSupport::HashWithIndifferentAccess.new({
#     title: 'A new entity arrives!',
#     body: 'Whasaaap?',
#     category: 'comment',
#     feed: 'github',
#     tags: ['issue_comment', 'canjs']
#   })
# end

# def updated_args
#   ActiveSupport::HashWithIndifferentAccess.new({
#     title: 'Changed title',
#     body: 'Changed body',
#     category: 'code',
#     feed: 'twitter',
#     tags: ['push_event', 'jquerypp']
#   })
# end
