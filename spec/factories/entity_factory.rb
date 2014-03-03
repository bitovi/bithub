FactoryGirl.define do

  factory :props, class:Hash do
    feed "some_feed"
    category "some_category"
    tags ['some_feed','some_category','some_content_tag']
    origin_author_id "1"
    origin_author_username "some_user"

    initialize_with { attributes }
  end

  factory :entity do
    title "Title"
    body "A body that has many many words in it."
    origin_ts Time.now
    thread_updated_ts Time.now
    props FactoryGirl.build(:props)

    trait :with_determined_feed do
      feed_name 'some_feed'
      association :feed, factory: :tag, name: "some_feed"
    end

    trait :with_determined_category do
      category_name 'some_category'
      association :category, factory: :tag, name: "some_category"
    end
    
    trait :with_determined_type do
      type_name 'some_type'
      association :type, factory: :tag, name: "some_type"
    end

    trait :with_determined_rule do
      association :scoring_rule, factory: :scoring_rule
    end

    trait :with_determined_tags do
      tag_list ['some_feed','some_category','some_content_tag']
    end

    trait :with_determined_author do
      association :author, factory: :user
    end

    factory :entity_wo_type     , traits: [:with_determined_tags, :with_determined_feed, :with_determined_category, :with_determined_rule    , :with_determined_author]
    factory :entity_wo_feed     , traits: [:with_determined_type, :with_determined_tags, :with_determined_category, :with_determined_rule    , :with_determined_author]
    factory :entity_wo_tags     , traits: [:with_determined_type, :with_determined_feed, :with_determined_category, :with_determined_rule    , :with_determined_author]
    factory :entity_wo_category , traits: [:with_determined_type, :with_determined_tags, :with_determined_feed    , :with_determined_rule    , :with_determined_author]
    factory :entity_wo_rule     , traits: [:with_determined_type, :with_determined_tags, :with_determined_feed    , :with_determined_category, :with_determined_author]
    factory :entity_wo_author   , traits: [:with_determined_type, :with_determined_tags, :with_determined_feed    , :with_determined_category, :with_determined_rule]

    factory :determined_entity  , traits: [:with_determined_type, :with_determined_tags, :with_determined_feed    , :with_determined_category, :with_determined_rule, :with_determined_author]

    # Forum entity

    factory :forum_entity do
      feed_name 'forums'
      category_name 'question'
      type_name 'post'

      tag_list %w(forum post question canjs)

      trait :forum_question do
        title "How do you do this?"
        body "I need help about an issue, and what to do ?"
        url "http://forums.com/some-question"
        origin_ts Time.now
      end

      trait :forum_reply do 
        title "Re: How do you do this?"
        sequence(:body) {|n| "#{n}. way to do this..." }
        sequence(:url) {|n| "http://forums.com/some-question##{n}" }
        sequence(:origin_ts) {|n| Time.now + (n+1).hour}
      end

      factory :forum_thread_starter, traits: [:forum_question, :with_determined_rule]
      factory :forum_child, traits: [:forum_reply, :with_determined_rule]
    end

    # Twitter entity

    factory :twitter_entity do
      feed_name 'twitter'
      category_name 'twitter'
      type_name 'tweet'

      association :feed, factory: :tag, name: "twitter"

      trait :tweet do
        type_name 'tweet'
        category_name 'twitter'
        association :type, factory: :tag, name: "tweet"
        association :category, factory: :tag, name: "twitter"
        tag_list %w(twitter tweet canjs)

        title "A hashtag #canjs and a @canjs mention."
      end

      trait :retweet do
        type_name 'tweet'
        category_name 'twitter'
        association :type, factory: :tag, name: "tweet"
        association :category, factory: :tag, name: "twitter"
        tag_list %w(twitter tweet canjs)

        title "RT: A hashtag #canjs and a @canjs mention."
      end

      trait :follow do
        type_name 'tweet'
        category_name 'twitter'
        association :type, factory: :tag, name: "tweet"
        association :category, factory: :tag, name: "twitter"
        tag_list %w(twitter follow canjs)

        title "followed @canjs"
      end

      factory :twitter_tweet, traits: [:with_determined_rule, :tweet]
      factory :twitter_retweet, traits: [:with_determined_rule, :retweet]
      factory :twitter_follow, traits: [:with_determined_rule, :follow]
    end

    # Github event

    factory :github_entity do
      feed_name 'github'
      association :feed, factory: :tag, name: "github"
      with_determined_rule
        
      factory :github_issue do
        type_name 'issue'
        category_name 'bug'
        association :type, factory: :tag, name: "issue"
        association :category, factory: :tag, name: "bug"
        tag_list %w(github issue bug canjs)

        title "raised issue #1"
      
        trait :with_source_data do
          source_data(issue_source_data)
        end
      end

      factory :github_push do
        type_name 'push'
        category_name 'code'
        association :type, factory: :tag, name: "push"
        association :category, factory: :tag, name: "code"
        tag_list %w(github push code canjs)

        trait :with_push_entity_source_data do
          source_data(push_entity_source_data)
        end
      end

      factory :github_pull_request do
        type_name 'pull_request'
        category_name 'code'
        association :type, factory: :tag, name: "pull_request"
        association :category, factory: :tag, name: "code"
        tag_list %w(github pull_request code canjs)

        title "requested a pull"
      end

      factory :github_issue_comment do
        type_name 'issue_comment'
        category_name 'github_comment'
        association :type, factory: :tag, name: "issue_comment"
        association :category, factory: :tag, name: "github_comment"
        tag_list %w(github issue_comment github_comment canjs)

        title "commented on issue #1"
        
        trait :with_source_data do
          source_data(issue_source_data)
        end
      end

      factory :github_watch_entity do
        type_name 'watch'
        category_name 'digest'
        association :type, factory: :tag, name: "watch"
        association :category, factory: :tag, name: "digest"
        tag_list %w(github watch digest canjs)

        title "started watching bitovi/canjs"
      end

      factory :github_commit_comment do
        type_name 'commit_comment'
        category_name 'github_comment'
        association :type, factory: :tag, name: "commit_comment"
        association :category, factory: :tag, name: "github_comment"
        tag_list %w(github commit_comment comment canjs)

        title "commented on a commit 4b2342hh"
      end
    end
  end
end
