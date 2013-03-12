FactoryGirl.define do
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
      :origin_author_id => "1"
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
    
    factory :event_wo_feed     , traits: [:with_determined_tags , :with_determined_category , :with_determined_rule     , :with_determined_author]
    factory :event_wo_tags     , traits: [:with_determined_feed , :with_determined_category , :with_determined_rule     , :with_determined_author]
    factory :event_wo_category , traits: [:with_determined_tags , :with_determined_feed     , :with_determined_rule     , :with_determined_author]
    factory :event_wo_rule     , traits: [:with_determined_tags , :with_determined_feed     , :with_determined_category , :with_determined_author]
    factory :event_wo_author   , traits: [:with_determined_tags , :with_determined_feed     , :with_determined_category , :with_determined_rule]
    factory :event_determined  , traits: [:with_determined_tags , :with_determined_feed     , :with_determined_category , :with_determined_rule, :with_determined_author]

    ### Forum event

    factory :forum_event do
      association :feed, factory: :tag, name: 'forums'
      association :category, factory: :tag, name: 'question'
      tag_list ['forums','question','canjs']

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

      factory :forum_thread_starter, traits: [:forum_question, :with_determined_rule]
      factory :forum_child, traits: [:forum_reply, :with_determined_rule]
    end

    ### Twitter event

    factory :twitter_event do
      association :feed, factory: :tag, name: 'twitter'
      association :category, factory: :tag, name: 'twitter'
      tag_list ['twitter','status_event','canjs']

      trait :tweet do
        title "A hashtag #canjs and a @canjs mention."
        meta({
          :feed => 'twitter',
          :tweet_id => "100",
          :type => "status_event",
          :origin_author_id => "123456"
        })
      end

      trait :retweet1 do
        title "RT: A hashtag #canjs and a @canjs mention."
        meta({
          :tweet_id => "101",
          :retweeted_id => "100",
          :type => "status_event"
        })
      end

      trait :retweet2 do
        title "RT: A hashtag #canjs and a @canjs mention."
        meta({
          :tweet_id => "102",
          :retweeted_id => "100",
          :type => "status_event"
        })
      end

      factory :twitter_tweet, traits: [:tweet, :with_determined_rule]
      factory :twitter_retweet1, traits: [:retweet1, :with_determined_rule]
      factory :twitter_retweet2, traits: [:retweet2, :with_determined_rule]
    end

    ### Github event

    factory :github_event do
      title "Some generic title"
      association :feed, factory: :tag, name: 'github'

      trait :issue do
        title "raised issue #1"
        body "I'm awesome because I raised an issue."
        association :category, factory: :tag, name: 'issue'
        tag_list ['github','issues_event','issue','canjs']
        meta({
          :feed => 'github',
          :type => "issues_event",
          :issue_id => "111",
          :origin_author_id => "456789"
        })
      end

      trait :issue_comment do
        title "commented on issue #1"
        association :category, factory: :tag, name: "comment"
        tag_list ['github','issue_comment_event','comment','canjs']
        sequence(:body) {|n| "Here's a comment no. ##{n} to your issue" }
        meta({
          :type => "issue_comment_event",
          :issue_id => "111"
        })
      end

      trait :push do
        title "pushed"
        body ""
        association :category, factory: :tag, name: "code"
        tag_list ['github','push_event','code','canjs']
        meta({
          :type => "push_event",
          :commits => "3sdaf4s,43a2aa8,295aa54",
        })
      end

      # how to generate commit hashes? (to avoid c/p)
      trait :commit_comment1 do
        title "commented on a commit 43a2aa8"
        body "This is an awesome comment"
        association :category, factory: :tag, name: "comment"
        tag_list ['github','commit_comment_event','comment','canjs']
        meta({
          :type => "commit_comment_event",
          :commit_id => "43a2aa8",
        })
      end

      trait :commit_comment2 do
        title "commented on a commit 295aa54"
        body "This is an awesome comment"
        association :category, factory: :tag, name: "comment"
        tag_list ['github','commit_comment_event','comment','canjs']
        meta({
          :type => "commit_comment_event",
          :commit_id => "295aa54",
        })
      end

      factory :github_issue, traits: [:issue, :with_determined_rule]
      factory :github_issue_comment, traits: [:issue_comment, :with_determined_rule]
      factory :github_push, traits: [:push, :with_determined_rule]
      factory :github_commit_comment1, traits: [:commit_comment1, :with_determined_rule]
      factory :github_commit_comment2, traits: [:commit_comment2, :with_determined_rule]
    end
  end
end
