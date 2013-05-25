require 'spec_helper'
require 'digest/md5'

describe Event do
  context "upon creation" do
    before :each do
      create(:rule)
    end

    describe "#bumb_thread" do
      it "updates event's updated_at attr"
    end

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
      it "calculates total nmb of upvotes for each event" do
        usr1 = create(:user); usr2 = create(:user)
        event = create(:event_determined)
        Upvote.create_upvote(usr1, event)
        Upvote.create_upvote(usr2, event)

        ev = Event.where(id: event.id).select_with_upvotes(true).first
        expect(ev.total_upvotes.to_i).to eq(2)
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
        expect(ev.hash).to be
      end

      it "sets the origin_date" do
        expect(ev.origin_date).to be
      end

      it "sets the origin_ts" do
        expect(ev.origin_ts).to be
      end
    end

    describe "#update_from_bithub" do
      before(:each) do
        @ev = Event.new_from_bithub(original_args)
        @ev.update_from_bithub!(updated_args)
      end

      it "re-determines the feed" do
        expect(@ev.feed).to eq(Event.determine_feed(updated_args[:feed]))
      end

      it "re-determines the category" do
        expect(@ev.category).to eq(Event.determine_category(updated_args[:category]))
      end

      it "re-determines tags" do
        expect(@ev.tag_list).to eq(Event.determine_tags(only_tags(updated_args)))
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

    describe ".determine_feed" do
      it "determines a feed using the name of the feed" do
        feed = Event.determine_feed("some_feed")
        tag_feed = Tag.find_by_name("some_feed")
        expect(feed).to eq(tag_feed)
      end
    end
    
    describe ".determine_category" do
      it "determines a category using the name of the category" do
        category = Event.determine_category("some_category")
        tag_category = Tag.find_by_name("some_category")
        expect(category).to eq(tag_category)
      end
    end
    
    describe ".determine_rule" do
      it "determines a rule using an array of tags" do
        rule = Event.determine_rule(['some_feed','some_category','some_project'])
        tag_rule = Rule.best_match(['some_feed','some_category','some_project'])
        expect(rule).to eq(tag_rule)
      end
    end

    describe "#determine_feed_from_meta" do
      it "determines a feed" do
        event = build(:event_wo_feed)        
        event.determine_feed_from_meta.save!
        feed = Tag.find_by_name(event.meta[:feed])
        expect(event.feed).to eq(feed)
      end
    end

    describe "#determine_category_from_meta" do
      it "determines a category" do
        event = build(:event_wo_category)        
        event.determine_category_from_meta.save!
        category = Tag.find_by_name(event.meta[:category])
        expect(event.category).to eq(category)
      end
    end

    describe "#determine_rule_from_meta" do
      it "determines a rule" do
        event = build(:event_wo_rule)        
        event.determine_rule_from_meta.save!
        rule = Rule.best_match(event.meta[:tags])
        expect(event.rule).to eq(rule)
      end
    end

    describe "#determine_tags_from_meta" do
      it "determines tags" do
        event = build(:event_wo_tags)
        event.determine_tags_from_meta.save!
        tags = Tag.find_or_create_all_with_like_by_name(['some_feed','some_category','some_content_tag'])
        event.tags.should =~(tags)        
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
          ghe.determine_author_from_meta.save!
          expect(ghe.author).to eq(@usr)
        end
        it "associates it with a twitter event" do
          twe = build(:twitter_tweet)
          twe.determine_author_from_meta.save!
          expect(twe.author).to eq(@usr)
        end
      end
    end

    describe "#process_forums" do
      before :each do
        @starter = build(:forum_thread_starter)
        @reply1 = build(:forum_child)
        @reply2 = build(:forum_child)
      end
      it "groups a thread starter with 2 replies" do
        @reply1.process_forums.save!
        @starter.process_forums.save!
        @reply2.process_forums.save!
        expect(@starter.reload.children.count).to eql(2)
        expect(@reply1.reload.parent_id).to eql(@starter.id)
        expect(@reply2.reload.parent_id).to eql(@starter.id)
      end
      it "groups replies without a thread starter" do
        @reply1.process_forums.save!
        @reply2.process_forums.save!
        expect(@reply1.children.count).to eql(1)
      end
    end

    describe "#process_github" do
      context "when grouping issue comments" do
        before :each do
          @issue = build(:github_issue)
          @issue_comment1 = build(:github_issue_comment)
          @issue_comment2 = build(:github_issue_comment)
        end
        it "groups issue comments with an issue" do
          @issue_comment1.process_github.save!
          @issue.process_github.save!
          @issue_comment2.process_github.save!
          expect(@issue.reload.children.count).to eql(2)
          expect(@issue_comment1.reload.parent_id).to eql(@issue.id)
          expect(@issue_comment2.reload.parent_id).to eql(@issue.id)
        end
        it "groups comments when there is no issue" do
          @issue_comment1.process_github.save!
          @issue_comment2.process_github.save!
          expect(@issue_comment2.reload.parent_id).to eql(@issue_comment1.id)        
        end
      end
      context "when grouping commit comments" do
        before :each do
          @push = build(:github_push)
          @commit_comment1 = build(:github_commit_comment1)
          @commit_comment2 = build(:github_commit_comment2)
        end
        it "groups a push event with 2 commit comments" do
          @commit_comment1.process_github.save!
          @push.process_github.save!
          @commit_comment2.process_github.save!
          expect(@push.reload.children.count).to eql(2)
          expect(@commit_comment1.reload.parent_id).to eql(@push.id)
          expect(@commit_comment2.reload.parent_id).to eql(@push.id)
        end
      end
    end

    describe "#process_twitter" do
      context "when grouping (re)tweets" do
        before :each do
          @tweet = build(:twitter_tweet)
          @retweet1 = build(:twitter_retweet1)
          @retweet2 = build(:twitter_retweet2)
        end
        it "groups a tweet with 2 retweets" do
          @retweet1.process_twitter.save!
          @tweet.process_twitter.save!
          @retweet2.process_twitter.save!
          expect(@tweet.reload.children.count).to eql(2)
          expect(@retweet1.reload.parent_id).to eql(@tweet.id)
          expect(@retweet2.reload.parent_id).to eql(@tweet.id)
        end
      end
    end
  end
end

def original_args
  {
    title: 'A new event arrives!',
    body: 'Whasaaap?',
    category: 'comment',
    feed: 'github',
    tags: ['issue_comment_event', 'canjs']
  }
end

def updated_args
  {
    title: 'Changed title',
    body: 'Changed body',
    category: 'code',
    feed: 'twitter',
    tags: ['push_event', 'jquerypp']
  }
end

def only_tags(args)
  Array[args[:category], args[:feed]].concat(args[:tags])
end
