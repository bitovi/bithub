require 'spec_helper'
require 'digest/md5'

describe Event do
  context "upon creation" do
    before(:all) { @default_rule = create(:rule) }
    after(:all) { @default_rule.destroy }

    describe "#initialize" do
      it "sets event id from DB sequence before saving" do
        event = build(:event_determined)
        id = event.id
        event.save!
        expect(event.reload.id).to eq(id)          
      end
    end

    describe "#save" do
      it "raises an error on save! b/c there is no feed / category / tags / rules applied" do
        generic_event = build(:event)
        expect{generic_event.save!}.to raise_error
      end
    end

    describe ".select_with_upvotes" do
      before :each do
        @event = create(:event_determined, rule: @default_rule, title: "Event in event_spec, testing .select_with_upvotes.")
        @user = create(:user, name: "Nikica")
      end

      it "gets upvotes as an Integer" do
        ev = Event.where(id: @event.id).select_with_upvotes.first
        expect(ev.total_upvotes).to be_an(Integer)
      end

      it "calculets upvotes" do
        Upvote.create_based_on_rule(@user, @event)
        ev = Event.where(id: @event.id).select_with_upvotes.first
        expect(ev.total_upvotes).to eq(1)
      end
    end

    describe "#new_from_bithub" do
      let(:args) { original_args }
      let(:ev) { Event.new_from_bithub(args) }

      it "determines tags" do
        expect(ev.tag_list).to be_instance_of(ActsAsTaggableOn::TagList)
      end

      it "determines a feed" do
        expect(ev.feed).to be_instance_of(Tag)
      end

      it "determines a category" do
        expect(ev.category).to be_instance_of(Tag)
      end

      it "assigns the body" do
        expect(ev.body).to be_instance_of(String)
      end

      it "assigns the title" do
        expect(ev.title).to be_instance_of(String)
      end

      it "calculates the hash key" do
        expect(ev.hash.class).to be
      end

      it "sets the origin and thread timestamps" do
        expect(ev.origin_ts).to be
        expect(ev.origin_date).to be
        expect(ev.thread_updated_at).to be
        expect(ev.thread_updated_date).to be
      end

    end

    describe "#update_from_bithub" do
      before(:each) do
        @ev = Event.new_from_bithub(original_args)
        @ev.update_from_bithub(updated_args)
      end

      it "re-determines the feed" do
        expect(@ev.feed).to eq(Tag.find_by_name(updated_args[:feed]))
      end

      it "re-determines the category" do
        expect(@ev.category).to eq(Tag.find_by_name(updated_args[:category]))
      end

      it "re-determines tags" do
        @ev.tag_list.should =~ only_tags(updated_args)
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

    describe ".prepare_commit" do
      it "should assign the 'custom_commit_event' as :type to new commits" do
        push = build(:github_push, :with_push_event_source_data, props: { type: "push_event", feed: "github", commits: "3sdaf4s,43a2aa8,295aa54" })
        prepared_event = Event.prepare_commit(push.source_data[:payload][:commits].first, push)

        expect(prepared_event[1][:type]).to eq('custom_commit_event')
      end
      
      it "should assign the commit SHA as the hash_key attribute to new commits" do
        push = build(:github_push, :with_push_event_source_data, props: { type: "push_event", feed: "github", commits: "3sdaf4s,43a2aa8,295aa54" })
        prepared_event = Event.prepare_commit(push.source_data[:payload][:commits].first, push)
        expect(prepared_event[0][:hash_key]).to eq(push.source_data[:payload][:commits][0][:sha])
      end

      it "should assign timestamps to new commits" do
        push = build(:github_push, :with_push_event_source_data, props: { type: "push_event", feed: "github", commits: "3sdaf4s,43a2aa8,295aa54" })
        prepared_event = Event.prepare_commit(push.source_data[:payload][:commits].first, push)
        expect(prepared_event[0][:origin_ts]).to be
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
  ([args[:feed]] + args[:tags])
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
