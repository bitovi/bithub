require 'spec_helper'
require 'digest/md5'

describe Event do

  context "upon creation" do
    before :each do
      create(:rule)
    end

    describe "#save" do
      it "raises an error on save! b/c there is no feed / category / tags / rules applied" do
        generic_event = build(:event)
        expect{generic_event.save!}.to raise_error
      end
    end

    describe "#determine_feed" do
      it "determines a feed" do
        event = build(:event_wo_feed)        
        event.determine_feed.save!
        feed = Tag.find_by_name(event.meta[:feed])
        expect(event.feed).to eq(feed)
      end
    end

    describe "#determine_category" do
      it "determines a category" do
        event = build(:event_wo_category)        
        event.determine_category.save!
        category = Tag.find_by_name(event.meta[:category])
        expect(event.category).to eq(category)
      end
    end

    describe "#determine_rule" do
      it "determines a rule" do
        event = build(:event_wo_rule)        
        event.determine_rule.save!
        rule = Rule.best_match(event.meta[:tags])
        expect(event.rule).to eq(rule)
      end
    end

    describe "#determine_tags" do
      it "determines tags" do
        event = build(:event_wo_tags)
        event.determine_tags.save!
        expect(event.tags.count).to eq(event.meta[:tags].count)        
      end
    end
    
    describe "#determine_author" do
      context "when there is an author in the system" do
        it "associates it with a github event" do
          ghe = build(:github_issue)
          usr = create(:user)
          ghe.determine_author
          ghe.save!
          expect(ghe.author).to eq(usr)
        end

        it "associates it with a twitter event" do
          twe = build(:twitter_tweet)
          usr = create(:user)
          twe.determine_author
          twe.save!
          expect(twe.author).to eq(usr)
        end
      end

      context "when there is no author in the system" do
        it "creates it and associates it with the event" do
          generic_event = build(:event_wo_author)
          generic_event.determine_author
          generic_event.save!
          expect(generic_event.author).to be
        end
      end

    end

    describe "#determine_all" do
      it "determines a feed, a category, a rule, tags and an author" do
        event = build(:event)
        event.determine_all
        event.save!
        feed = Tag.find_by_name(event.meta[:feed])
        category = Tag.find_by_name(event.meta[:category])
        rule = Rule.best_match(event.meta[:tags])
        
        expect(event.feed).to eq(feed)
        expect(event.category).to eq(category)
        expect(event.rule).to eq(rule)
        expect(event.tags.count).to eq(event.meta[:tags].count)        
        expect(event.tags.count).to eq(event.meta[:tags].count)        
      end
    end

    context "when grouping forum events" do
      before :each do
        @starter = build(:forum_thread_starter)
        @reply1 = build(:forum_child)
        @reply2 = build(:forum_child)
      end

      it "there should be a thread starter without children" do
        @starter.process_forums.save!
        expect(@starter.parent).to be_nil
      end

      it "there should be thread with 2 replies" do
        @reply1.process_forums.save!
        @starter.process_forums.save!
        @reply2.process_forums.save!
        expect(@starter.reload.children.count).to eql(2)
        expect(@reply1.reload.parent_id).to eql(@starter.id)
        expect(@reply2.reload.parent_id).to eql(@starter.id)
      end

      it "there should be two replies grouped without thread" do
        @reply1.process_forums.save!
        @reply2.process_forums.save!
        expect(@reply1.children.count).to eql(1)
      end
    end

    context "when grouping github issues" do
      before :each do
        @issue = build(:github_issue)
        @issue_comment1 = build(:github_issue_comment)
        @issue_comment2 = build(:github_issue_comment)
      end

      it "there should be issue with 2 comments" do
        @issue_comment1.process_github.save!
        @issue.process_github.save!
        @issue_comment2.process_github.save!
        expect(@issue.reload.children.count).to eql(2)
        expect(@issue_comment1.reload.parent_id).to eql(@issue.id)
        expect(@issue_comment2.reload.parent_id).to eql(@issue.id)
      end

      it "there should be 2 grouped comments without issue" do
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
          
      it "there should be push event with 2 commit comments" do
        @commit_comment1.process_github.save!
        @push.process_github.save!
        @commit_comment2.process_github.save!
        expect(@push.reload.children.count).to eql(2)
        expect(@commit_comment1.reload.parent_id).to eql(@push.id)
        expect(@commit_comment2.reload.parent_id).to eql(@push.id)
      end
    end

    context "when grouping (re)tweets" do
      before :each do
        @tweet = build(:twitter_tweet)
        @retweet1 = build(:twitter_retweet1)
        @retweet2 = build(:twitter_retweet2)
      end

      it "there should be tweet with 2 retweets" do
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
