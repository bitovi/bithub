FactoryGirl.define do

  factory :event do
    origin_date Date.today
    origin_ts Time.now
    hash_key { Digest::MD5.hexdigest(title + body) }
    raw_json "{}"
    props({})

    factory :forum_event do
      props({
        :feed => "forums",
        :category => "question",
        :tags => ["forums", "question", "canjs"]
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
      props({
        :feed => "twitter",
        :type => "status_event",
        :tags => ["twitter", "status_event", "canjs"]
      })

      trait :tweet do
        title "A hashtag #canjs and a @canjs mention."
      end

      trait :retweet do
        title "RT: A hashtag #canjs and a @canjs mention."
      end

      factory :twitter_tweet, traits: [:tweet]
      factory :twitter_retweet, traits: [:retweet]
    end

    factory :github_event do
      title "Some generic title"
      
      trait :issue do
        title "raised issue #1"
        body "I'm awesome because I raised an issue."
        props({
          :feed => "github",
          :type => "issues_event",
          :category => "issue",
          :tags => ["github", "issues_event", "issue", "canjs"]
        })
      end

      trait :issue_comment do
        title "commented on issue #1"
        body "Here's a comment to your issue"
        props({
          :feed => "github",
          :type => "issue_comment_event",
          :category => "comment",
          :tags => ["github", "issue_comment_event", "comment", "canjs"]
        })
      end

      trait :commit_comment do
        title "commented on a commit 3sdaf4s"
        body "This is an awesome comment"
        props({
          :feed => "github",
          :type => "commit_comment_event",
          :category => "comment",
          :tags => ["github", "comment_comment_event", "comment", "canjs"]
        })
      end

      factory :github_issue, traits: [:issue]
      factory :github_issue_comment, traits: [:issue_comment]
      factory :github_commit_comment, traits: [:commit_comment]
    end
  end
end
