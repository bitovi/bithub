require 'spec_helper'

describe Grouping do

  before(:all) { @default_rule = create(:rule) }
  after(:all) { @default_rule.destroy }


  describe "#group_issues_event" do
    before :each do
      Event.any_instance.stub(:update_self_from_child) { false }
    end

    context "when there already exist instances of the issue, and are a closers/reopeners" do
      it "adopts those instances as it's children" do
        i1 = create(:github_issue, props: {issue_id: "123", action: "closed"})
        i2 = create(:github_issue, props: {issue_id: "123", action: "reopened"})
        ni = build(:github_issue, props: {issue_id: "123", action: "opened"})
        ni.group_issues_event.save!
        ni.children.should =~ [i1, i2]
      end
    end

    context "when there already exists an instance of the issue, and it is a opener" do
      it "sets that issue as its parent" do
        i = create(:github_issue, props: {issue_id: "123", action: "opened"})
        ni = build(:github_issue, props: {issue_id: "123", action: "closed"})
        ni.group_issues_event.save!
        ni.parent.should == i
      end
    end

    context "when there exist one/more related issue comments" do
      it "should adopt those as its children" do
        c1 = create(:github_issue_comment, props: {repo_name: 'bithub-test/testy', issue_number: "7"}, title: "Vel said...")
        c2 = create(:github_issue_comment, props: {repo_name: 'bithub-test/testy', issue_number: "7"}, title: "Nik said...")
        nie = build(:github_issue, props: {repo_name: 'bithub-test/testy', issue_number: "7"}, title: "Justin raised...")
        nie.group_issues_event.save!
        nie.children.should =~ [c1, c2]
      end

      context "and some of those have their own children" do
        it "should adopt them and their children as its own"
        it "should not adopt duplicate children"
      end

    end

    context "when there exist one/more related pull requests" do
      it "shoul adopt those as its children" do
        pr = create(:github_pull_request, props: {
          repo_name: "bitovi/canjs",
          referenced_issue_number: "67",
          issue_id: "987",
          issue_number: "134"
        })

        nie = build(:github_issue, props: {repo_name: "bitovi/canjs", issue_id: "123", issue_number: "67"}, title: "Justin raised...")
        nie.group_issues_event.save!
        nie.children.should =~ [pr]
      end
    end

    context "when there exist one/more related pushes" do
      it "should adopt those as its children" do
        p = create(:github_push, props: {
          repo_name: "bitovi/canjs",
          referenced_issue_number: "67",
          commits: "22n542f,35hsdlj2",
          all_messages: ""
        })

        nie = build(:github_issue, props: {repo_name: "bitovi/canjs", issue_id: "123", issue_number: "67"}, title: "Justin raised...")
        nie.group_issues_event.save!
        nie.children.should =~ [p]
      end
    end
  end
  

  describe "#group_push_event" do

    context "when there exist one/more related commit comments" do
      it "should adopts those as its children" do
        c1 = create(:github_commit_comment, props: {commit_sha: "a3h9dj2"}, title: "This is a bad commit.")
        c2 = create(:github_commit_comment, props: {commit_sha: "23jy602"}, title: "This is a good commit.")
        npe = build(:github_push, props: {commit_shas: "a3h9dj2,23jy602"}, title: "Pushed 2 commits")
        npe.stub(:split_push_event_to_commits)
        npe.group_push_event.save!
        npe.children.should =~ [c1, c2]
      end

      context "and some of those have their own children" do
        it "should adopt them and their children as its own"
        it "should not adopt duplicate children"
      end
    end

    context "when the push references another issue and there exists such an issue" do
      it "should set that issue as its parent" do
        i = create(:github_issue, props: {issue_id: "12345", issue_number: "76", repo_name: "bitovi/canjs"}, title: "This is broken!")
        npe = build(:github_push, props: {referenced_issue_number: "76", repo_name: "bitovi/canjs"})
        npe.stub(:split_push_event_to_commits)
        npe.group_push_event.save!
        npe.parent.should == i
      end
    end
  end
  

  describe "#group_pull_request_event" do
    context "when there exist one/more related pull-request comments" do
      it "should adopt those as its children" do
        c1 = create(:github_issue_comment, props: {repo_name: "bithub-test/testy", issue_number: "7"}, title: "This is OK to merge.")
        c2 = create(:github_issue_comment, props: {repo_name: "bithub-test/testy", issue_number: "7"}, title: "Can't merge this yo.")
        npre = build(:github_pull_request, props: {repo_name: "bithub-test/testy", issue_number: "7"}, title: "Guys, look at this cool new feature.")
        npre.group_pull_request_event.save!
        npre.children.should =~ [c1, c2]
      end
      
      context "and some of those have their own children" do
        it "should adopt them and their children as its own"
        it "should not adopt duplicate children"
      end
    end

    context "when the pull-request references another issue and there exists such an issue" do
      it "should set that issue as its parent" do
        i = create(:github_issue, props: {issue_number: "76", repo_name: "bitovi/canjs"}, title: "This is broken!")
        npre = build(:github_pull_request, props: {referenced_issue_number: "76", repo_name: "bitovi/canjs"}, title: "Hey guys, merge this pretty please!")
        npre.group_pull_request_event.save!
        npre.parent.should == i
      end
    end
  end


  describe "#group_issue_comment_event" do
    before :each do
      Event.any_instance.stub(:update_self_from_child) { false }
    end

    context "when there exists a related issue comment" do
      it "should set that issue comment as its parent" do
        ec = create(:github_issue_comment, props: {issue_id: "123"}, title: "Veljko commented on something")
        nc = build(:github_issue_comment, props: {issue_id: "123"}, title: "Nikica also commented")
        nc.group_issue_comment_event.save!
        nc.parent.should == ec
      end
    end

    context "when there are multiple related issue comments" do
      it "should set the one that came first as its parent"
    end

    context "when there is a related issue" do
      it "should set that issue as its parent" do
        i = create(:github_issue, props: {issue_id: "123"}, title: "Someone found a bug!")
        nic = build(:github_issue_comment, props: {issue_id: "123"}, title: "That's not a bug yo!")
        nic.group_issue_comment_event.save!
        nic.parent.should == i
      end
    end
  end


  describe "#group_commit_comment_event" do
    context "when there exists a related commit comment in the system" do
      it "should set that commit comment as its parent" do
        cc = create(:github_commit_comment, props: {commit_sha: "sdf2rb34s"}, title: "Are you mad? It's just printing a string")
        ncc = build(:github_commit_comment, props: {commit_sha: "sdf2rb34s"}, title: "He's right, it does.")
        ncc.group_commit_comment_event.save!
        ncc.parent.should == cc
      end
    end
    
    context "when there are multipe related commit comment in the system" do
      it "should set the one that came first as the parent"
    end

    context "when there is a related push in the system" do
      it "should set that push as its parent" do
        p = create(:github_push, props: {commit_shas: "432nrfs,34k2nsdf2", referenced_issue_number: "76", repo_name: "bitovi/canjs"})
        ncc = build(:github_commit_comment, props: {commit_sha: "432nrfs"}, title: "This is a bad commit.")
        ncc.group_commit_comment_event.save!
        ncc.parent.should == p
      end
    end
  end


  describe "#split_push_event_to_commits" do
    it "should create a number of commits equal to length of the commits hash" do
      push = build(:github_push, :with_push_event_source_data)
      expect(push.split_push_event_to_commits.length).to eql 2
    end

    it "should copy the PushEvent's tags to CustomCommitEvent" do
      push = build(:github_push, :with_push_event_source_data)
      push.split_push_event_to_commits.first.tag_list.should include(*push.tag_list)
    end
  end

  describe "#update_parent_issue" do
    before :each do
      @i = create(:github_issue, title: "Wat.", body: "Wat?", props: {state: "open", issue_id: "123", labels: ['wat']})
      @ni = build(:github_issue, :with_source_data, props: {issue_id: "123"})
      @i.update_self_from_child(@ni)
    end
    
    it "should update the title of the parent issue" do
      @i.reload.title.should == @ni.source_data[:payload][:issue][:title]
    end

    it "should update the body of the parent issue" do
      @i.reload.body.should == @ni.source_data[:payload][:issue][:body]
    end

    it "should update the labels of the parent issue" do
      @i.reload.props['labels'].should == @ni.source_data[:payload][:issue][:labels].map{|l| l[:name]}.join(',')
    end

    it "should update the state of the parent issue" do
      @i.reload.props['state'].should == @ni.source_data[:payload][:issue][:state]
    end
  end

  describe "#group_tweet" do
    context "when there are existing retweets of itself" do
      it "adopts those as children" do
        rt1 = create(:twitter_retweet, props: {tweet_id: "101", retweeted_id: "100"})
        rt2 = create(:twitter_retweet, props: {tweet_id: "102", retweeted_id: "100"})
        t = build(:twitter_tweet, props: {tweet_id: "100"})
        t.group_tweet.save!
        t.children.should =~ [rt1, rt2]
      end
    end

    context "when there are exiting retweets of itself, and one of those has childrend" do
      it "should adopt all the retweets and their children" do
        rt1 = create(:twitter_retweet, props: {tweet_id: "101"})
        rt2 = create(:twitter_retweet, props: {tweet_id: "102", retweeted_id: "100"}, children: [rt1])
        t = build(:twitter_tweet, props: {tweet_id: "100"})
        t.group_tweet.save!
        t.children.should =~ [rt1, rt2]
      end

      it "should not have duplicate children" do
        rt1 = create(:twitter_retweet, props: {tweet_id: "101", retweeted_id: "100"})
        rt2 = create(:twitter_retweet, props: {tweet_id: "102", retweeted_id: "100"}, children: [rt1])
        t = build(:twitter_tweet, props: {tweet_id: "100"})
        t.group_tweet.save!
        t.children.should =~ [rt1, rt2]
      end
    end
  end

  describe "#group_retweet" do
    context "when there exists the original tweet" do
      it "sets that tweet as its parent" do
        t = create(:twitter_tweet, props: {tweet_id: "100"}, title: "Hey, check this out, http:///canjs.com")
        rt = build(:twitter_retweet, props: {tweet_id: "101", retweeted_id: "100"})
        rt.group_retweet.save!
        rt.parent.should == t
      end
    end

    context "when there is no original tweet, only another retweet" do
      it "sets the retweet as its parent" do
        rt = create(:twitter_retweet, props: {tweet_id: "100", retweeted_id: "99"})
        nrt = build(:twitter_retweet, props: {twett_id: "101", retweeted_id: "99"})
        nrt.group_retweet.save!
        nrt.parent.should == rt
      end
    end
  end

  

  describe "#group_forum_post" do
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

end
