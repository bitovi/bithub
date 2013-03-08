require 'spec_helper'
require 'digest/md5'

describe Event do

  context "upon creation" do
    before :each do
      create(:rule)
    end

    it "raises an error on save! b/c there is no feed / category / tags / rules applied" do
      generic_event = build(:event)
      expect{generic_event.save!}.to raise_error
    end

    it "determines feed, category, rule and tags" do
      generic_event = build(:event)
      generic_event.whole_chain
      generic_event.save!
      feed = Tag.find_or_create(generic_event.meta[:feed])
      category = Tag.find_or_create(generic_event.meta[:category])
      rule = Rule.best_match(generic_event.meta[:tags])

      expect(generic_event.feed).to eq(feed)
      expect(generic_event.category).to eq(category)
      expect(generic_event.rule).to eq(rule)
    end

    context "when there is an author in the system" do
      it "associates it" do
        generic_event = build(:twitter_tweet)
        generic_user = create(:author)
        generic_event.determine_author
        generic_event.save!
        expect(generic_event.author).to eq(generic_user)
      end
    end

    context "when there is no author in the system" do
      it "creates it and associates it with the event" do
        generic_event = build(:twitter_tweet)
        generic_event.determine_author
        generic_event.save!
        expect(generic_event.author).to be
      end
    end

    context "when grouping forum events" do
      before :each do
        @starter = build(:forum_thread_starter)
        @reply1 = build(:forum_child)
        @reply2 = build(:forum_child)
      end

      it "there should be a thread starter without children" do
        @starter.whole_chain.save!
        expect(@starter.parent).to be_nil
      end

      it "there should be thread with 2 replies" do
        @reply1.whole_chain.save!
        @starter.whole_chain.save!
        @reply2.whole_chain.save!
        expect(@starter.reload.children.count).to eql(2)
        expect(@reply1.reload.parent_id).to eql(@starter.id)
        expect(@reply2.reload.parent_id).to eql(@starter.id)
      end

      it "there should be two replies grouped without thread" do
        @reply1.whole_chain.save!
        @reply2.whole_chain.save!
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
        @issue_comment1.whole_chain.save!
        @issue.whole_chain.save!
        @issue_comment2.whole_chain.save!
        expect(@issue.reload.children.count).to eql(2)
        expect(@issue_comment1.reload.parent_id).to eql(@issue.id)
        expect(@issue_comment2.reload.parent_id).to eql(@issue.id)
      end

      it "there should be 2 grouped comments without issue" do
        @issue_comment1.whole_chain.save!
        @issue_comment2.whole_chain.save!
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
        @commit_comment1.whole_chain.save!
        @push.whole_chain.save!
        @commit_comment2.whole_chain.save!
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
        @retweet1.whole_chain.save!
        @tweet.whole_chain.save!
        @retweet2.whole_chain.save!
        expect(@tweet.reload.children.count).to eql(2)
        expect(@retweet1.reload.parent_id).to eql(@tweet.id)
        expect(@retweet2.reload.parent_id).to eql(@tweet.id)
      end
    end

  end
end
