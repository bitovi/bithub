require_relative 'support/spec_helper'

describe Entity do

  before(:all) { import_tags }
  after(:all) { Tag.destroy_all }

  context "upon creation" do
    before(:all) { @default_rule = create(:scoring_rule) }
    after(:all) { @default_rule.destroy }

    describe "#save" do
      it "raises an error on save! b/c there is no feed / category / tags / rules applied" do
        generic_event = build(:event)
        expect{generic_event.save!}.to raise_error
      end
    end

    describe ".has_an_attribute?" do
      context "symbol given" do
        it "confirms that the Event model indeed has an attribute" do
          expect(Event.has_an_attribute?(:title)).to be_true
        end

        it "denies that the Event model has a non-existent attribute" do
          expect(Event.has_an_attribute?(:titles)).to be_false
        end
      end
      
      context "string given" do
        it "confirms that the Event model indeed has an attribute" do
          expect(Event.has_an_attribute?("title")).to be_true
        end

        it "denies that the Event model has a non-existent attribute" do
          expect(Event.has_an_attribute?("titles")).to be_false
        end
      end
    end


    describe "#thread" do
      it "fetches the event itself wrapped in an array if there is no thread" do
        e = create(:github_issue, title: "Why is this happening?")
        e.thread.should =~ [e]
      end
      
      it "fetches the whole thread" do
        pe = create(:github_issue, title: "Why is this happening?")
        ce1 = create(:github_issue_comment, title: "I don't care.", parent: pe)
        ce2 = create(:github_issue_comment, title: "Wat? Qua?", parent: pe)
        pe.thread.should =~ ce1.thread
        expect(pe.thread.length).to eql(3)
      end
    end

    describe "#bump_thread" do
      it "updates the thread_updated_at attribute for all events in a thread" do
        pe = create(:github_issue, title: "Why is this happening?", origin_ts: Time.now+5)
        ce1 = create(:github_issue_comment, title: "I don't care.", parent: pe, origin_ts: Time.now+10)
        ce2 = create(:github_issue_comment, title: "Wat? Qua?", parent: pe, origin_ts: Time.now+15)

        ce2.bump_thread
        pe.reload.thread_updated_at.should > pe.origin_ts
        ce1.reload.thread_updated_at.should > ce1.origin_ts
        ce2.reload.thread_updated_at.should == ce2.origin_ts
      end
    end

    describe "#cache_key" do
      before(:each) { @event = create(:event_determined, title: "Event in event_spec, testing #cache_key", updated_at: nil, thread_updated_at: nil) }

      it "uses the id and the updated_at timestamp when it is present" do
        expect(@event.reload.cache_key).to eq "events/#{@event.id}-#{@event.updated_at.utc.to_s(:number)}"
      end

      it "uses the id, updated_at and thread_updated_at timestamps when they are present" do
        @event.update_attribute(:thread_updated_at, Time.now)
        expect(@event.reload.cache_key).to eq "events/#{@event.id}-#{@event.updated_at.utc.to_s(:number)}-#{@event.thread_updated_at.utc.to_s(:number)}"
      end
    end
  end
end

def original_args
  ActiveSupport::HashWithIndifferentAccess.new({
    title: 'A new event arrives!',
    body: 'Whasaaap?',
    category: 'comment',
    feed: 'github',
    tags: ['issue_comment_event', 'canjs']
  })
end

def updated_args
  ActiveSupport::HashWithIndifferentAccess.new({
    title: 'Changed title',
    body: 'Changed body',
    category: 'code',
    feed: 'twitter',
    tags: ['push_event', 'jquerypp']
  })
end

def only_tags(args)
  ([args[:category], args[:feed]] + args[:tags])
end

def push_event
{ 
    push_id: 223206323,
    size: 2,
    distinct_size: 2,
    ref: "refs/heads/canComponent",
    head: "ae8c72c7e1d0639117dee0bc46cab0a741dc442d",
    before: "5068c01920cf40e7af1536a6adf8457a3f10ef67",
    commits: [{
      sha: "b824b74af1eb7fe33304b80c4f7ab9b5a050090f",
      author: {
        email: "justinbmeyer@gmail.com",
        name: "Justin Meyer"
      },
      message: "all tests pass in FF and Chrome in for all libraries",
      distinct: true,
      url: "https://api.github.com/repos/bitovi/canjs/commits/b824b74af1eb7fe33304b80c4f7ab9b5a050090f"
    }, {
      sha: "ae8c72c7e1d0639117dee0bc46cab0a741dc442d",
      author: {
        email: "neektza@gmail.com",
        name: "Nikica Jokic"
      },
      message: "started documenting components",
      distinct: true,
      url: "https://api.github.com/repos/bitovi/canjs/commits/ae8c72c7e1d0639117dee0bc46cab0a741dc442d"
    }]
}
end
