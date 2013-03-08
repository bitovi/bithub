FactoryGirl.define do
  sequence :origin_author_id do |n|
    n
  end

  factory :event do
    title "Title"
    body "Body"
    origin_date Date.today
    origin_ts Time.now
    sequence(:hash_key) {|n| Digest::MD5.hexdigest(title + body + n.to_s) }
    meta({
      :feed => "some_feed",
      :category => "some_category",
      :tags => ['some_feed','some_category','some_content_tag'],
      :origin_author_id => proc { origin_author_id } 
    })

    trait :with_determined_feed do
      association :feed, factory: :tag, name: "some_feed"
    end

    trait :with_determined_category do
      association :category, factory: :tag, name: "some_category"
    end

    trait :with_determined_rule do
      association :rule, factory: :rule
    end

    trait :with_determined_tags do
      tag_list ['some_feed','some_category','some_content_tag']
    end

    trait :with_determined_author do
      association :author, factory: :user
    end

    factory :event_wo_tags     , traits: [:with_determined_feed , :with_determined_category , :with_determined_rule     , :with_determined_author]
    factory :event_wo_feed     , traits: [:with_determined_tags , :with_determined_category , :with_determined_rule     , :with_determined_author]
    factory :event_wo_category , traits: [:with_determined_tags , :with_determined_feed     , :with_determined_rule     , :with_determined_author]
    factory :event_wo_rule     , traits: [:with_determined_tags , :with_determined_feed     , :with_determined_category , :with_determined_author]
    factory :event_wo_author   , traits: [:with_determined_tags , :with_determined_feed     , :with_determined_category , :with_determined_rule]

    factory :forum_event do
      meta({
        :feed => "forums",
        :category => "question",
        :tags => ['forums','question','canjs']
      })

      trait :forum_question do
        title "How do you do this?"
        body "I need help about an issue, and what to do ?"
        url "http://forums.com/some-question"
      end

      trait :forum_reply do 
        title "Re: How do you do this?"
        sequence(:body) {|n| "#{n}. way to do this..." }
        sequence(:url) {|n| "http://forums.com/some-question##{n}" }
      end

      factory :forum_thread_starter, traits: [:forum_question]
      factory :forum_child, traits: [:forum_reply]
    end

    factory :twitter_event do

      trait :tweet do
        title "A hashtag #canjs and a @canjs mention."
        meta({
          :tweet_id => "100",
          :feed => "twitter",
          :type => "status_event",
          :category => "twitter",
          :tags => ['twitter','status_event','canjs'],
          :origin_author_id => 123456789
        })
      end

      trait :retweet1 do
        title "RT: A hashtag #canjs and a @canjs mention."
        meta({
          :tweet_id => "101",
          :retweeted_id => "100",
          :feed => "twitter",
          :type => "status_event",
          :category => "twitter",
          :tags => ['twitter','status_event','canjs']
        })
      end

      trait :retweet2 do
        title "RT: A hashtag #canjs and a @canjs mention."
        meta({
          :tweet_id => "102",
          :retweeted_id => "100",
          :feed => "twitter",
          :type => "status_event",
          :category => "twitter",
          :tags => ['twitter','status_event','canjs']
        })
      end

      factory :twitter_tweet, traits: [:tweet]
      factory :twitter_retweet1, traits: [:retweet1]
      factory :twitter_retweet2, traits: [:retweet2]
    end

    factory :github_event do
      title "Some generic title"

      trait :issue do
        title "raised issue #1"
        body "I'm awesome because I raised an issue."
        meta({
          :feed => "github",
          :type => "issues_event",
          :category => "issue",
          :issue_id => "111",
          :tags => ['github','issues_event','issue','canjs']
        })
      end

      trait :issue_comment do
        title "commented on issue #1"
        sequence(:body) {|n| "Here's a comment no. ##{n} to your issue" }
        meta({
          :feed => "github",
          :type => "issue_comment_event",
          :issue_id => "111",
          :tags => ['github','issue_comment_event','comment','canjs'],
          :category => "comment"
        })
      end

      trait :push do
        title ""
        body ""
        meta({
          :feed => "github",
          :type => "push_event",
          :commits => "3sdaf4s,43a2aa8,295aa54",
          :tags => ['github','push_event','code','canjs'],
          :category => "code"
        })
      end

      # how to generate commit hashes? (to avoid c/p)
      trait :commit_comment1 do
        title "commented on a commit 43a2aa8"
        body "This is an awesome comment"
        meta({
          :feed => "github",
          :type => "commit_comment_event",
          :commit_id => "43a2aa8",
          :tags => ['github','commit_comment_event','comment','canjs'],
          :category => "comment"
        })
      end

      trait :commit_comment2 do
        title "commented on a commit 295aa54"
        body "This is an awesome comment"
        meta({
          :feed => "github",
          :type => "commit_comment_event",
          :commit_id => "295aa54",
          :tags => ['github','commit_comment_event','comment','canjs'],
          :category => "comment"
        })
      end

      factory :github_issue, traits: [:issue]
      factory :github_issue_comment, traits: [:issue_comment]
      factory :github_push, traits: [:push]
      factory :github_commit_comment1, traits: [:commit_comment1]
      factory :github_commit_comment2, traits: [:commit_comment2]
    end
  end
end
