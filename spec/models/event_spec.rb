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

    describe "#determine_feed" do
      it "determines a feed" do
        event = build(:event_wo_feed)        
        event.determine_feed.save!
        feed = Tag.find_by_name(event.props['feed'])
        expect(event.feed).to eq(feed)
      end
    end

    describe "#determine_category" do
      it "determines a category" do
        event = build(:event_wo_category)        
        event.determine_category.save!
        category = Tag.find_by_name(event.props['category'])
        expect(event.category).to eq(category)
      end
    end

    describe "#determine_rule" do
      it "determines a rule" do
        event = build(:event_wo_rule)        
        event.determine_rule.save!
        rule = Rule.best_match(event.props[:tags])
        expect(event.rule).to eq(rule)
      end
    end

    describe "#determine_tags" do
      it "determines tags" do
        event = build(:event_wo_tags)
        event.determine_tags.save!
        tags = Tag.find_or_create_all_with_like_by_name(['some_feed','some_category','some_content_tag'])
        event.tags.should =~ tags
      end
    end

    describe "#determine_author" do
      context "when there is an author in the system" do
        before(:each) do
          @usr = create(:user, name: "Nikica")
          ident = create(:identity, uid: 123456, provider: "twitter", user: @usr)
          ident = create(:identity, uid: 456789, provider: "github", user: @usr)
        end
        it "associates it with a github event" do
          ghe = build(:github_issue)
          ghe.determine_author.save!
          expect(ghe.author).to eq(@usr)
        end
        it "associates it with a twitter event" do
          twe = build(:twitter_tweet)
          twe.determine_author.save!
          expect(twe.author).to eq(@usr)
        end
      end
    end

    describe "#group_forums" do
      before :each do
        @starter = build(:forum_thread_starter)
        @reply1 = build(:forum_child)
        @reply2 = build(:forum_child)
      end
      it "groups a thread starter with 2 replies" do
        @reply1.group_forums.save!
        @starter.group_forums.save!
        @reply2.group_forums.save!
        expect(@starter.reload.children.count).to eql(2)
        expect(@reply1.reload.parent_id).to eql(@starter.id)
        expect(@reply2.reload.parent_id).to eql(@starter.id)
      end
      it "groups replies without a thread starter" do
        @reply1.group_forums.save!
        @reply2.group_forums.save!
        expect(@reply1.children.count).to eql(1)
      end
    end

    describe "#group_github" do
      context "when grouping issue comments" do
        before :each do
          @issue = build(:github_issue)
          @issue_comment1 = build(:github_issue_comment)
          @issue_comment2 = build(:github_issue_comment)
        end
        it "groups issue comments with an issue" do
          @issue_comment1.group_github.save!
          @issue.group_github.save!
          @issue_comment2.group_github.save!
          expect(@issue.reload.children.count).to eql(2)
          expect(@issue_comment1.reload.parent_id).to eql(@issue.id)
          expect(@issue_comment2.reload.parent_id).to eql(@issue.id)
        end
        it "groups comments when there is no issue" do
          @issue_comment1.group_github.save!
          @issue_comment2.group_github.save!
          expect(@issue_comment2.reload.parent_id).to eql(@issue_comment1.id)        
        end
      end
      context "when grouping commit comments" do
        before :each do
          @push = build(:github_push, title: "Printing a string raises an error, here's a code sample")
          @commit_comment1 = build(:github_commit_comment1, title: "Are you mad? It's just printing a string")
          @commit_comment2 = build(:github_commit_comment2, title: "He's right, it does.")
        end
        it "groups a push event with 2 commit comments" do
          @commit_comment1.group_github.save!
          @push.group_github.save!
          @commit_comment2.group_github.save!
          expect(@push.reload.children.count).to eql(2)
          expect(@commit_comment1.reload.parent_id).to eql(@push.id)
          expect(@commit_comment2.reload.parent_id).to eql(@push.id)
        end
      end
    end

    describe "#group_twitter" do
      context "when grouping (re)tweets" do
        before :each do
          @tweet = build(:twitter_tweet, title: "Hey, check this out, http:///canjs.com")
          @retweet1 = build(:twitter_retweet1, title: "RT: Hey, check this out, http:///canjs.com")
          @retweet2 = build(:twitter_retweet2, title: "RT Hey, check this out, http:///canjs.com")
        end
        it "groups a tweet with 2 retweets" do
          @retweet1.group_twitter.save!
          @tweet.group_twitter.save!
          @retweet2.group_twitter.save!
          expect(@tweet.reload.children.count).to eql(2)
          expect(@retweet1.reload.parent_id).to eql(@tweet.id)
          expect(@retweet2.reload.parent_id).to eql(@tweet.id)
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

    describe "#clean_props_after_categorization" do
      it "cleans props from attributes that should't get saved in hstore"
    end

    describe ".pluck_and_clean_for_bithub" do
      it "transforms arguments received from bithub-client into stuff for hstore and stuff for filling collumns"
    end

    describe ".origin_and_thread_to_now" do
      it "sets thread and origin timestamps to current time"
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
