push_event_source_data = {
  id: "1822604055",
  type: "PushEvent",
  actor: {
    id: 252054,
    login: "imjoshdean",
    gravatar_id: "3282bba910cbf2936251e351f1405c26",
    url: "https://api.github.com/users/imjoshdean",
    avatar_url: "https://1.gravatar.com/avatar/3282bba910cbf2936251e351f1405c26?d=https%3A%2F%2Fa248.e.akamai.net%2Fassets.github.com%2Fimages%2Fgravatars%2Fgravatar-user-420.png"
  },
  repo: {
    id: 3228363,
    name: "bitovi/canjs",
    url: "https://api.github.com/repos/bitovi/canjs"
  },
  payload: {
    push_id: 224663608,
    size: 2,
    distinct_size: 2,
    ref: "refs/heads/master",
    head: "1107f77cc5074b7ad9b7f628afb43bc703325111",
    before: "d567f296b998eddedde0f709e58790e646d194c9",
    commits: [{
      sha: "7d7a87304943e1de9d019bf07d33dc9413a13181",
      author: {
        email: "imjoshdean@me.com",
        name: "Josh Dean"
      },
      message: "Update EJS documentation. Clean up some issues and wording.",
      distinct: true,
      url: "https://api.github.com/repos/bitovi/canjs/commits/7d7a87304943e1de9d019bf07d33dc9413a13181"
    }, {
      sha: "1107f77cc5074b7ad9b7f628afb43bc703325111",
      author: {
        email: "imjoshdean@me.com",
        name: "Josh Dean"
      },
      message: "Update can.Model documentation. Clean up some issues and wording.",
      distinct: true,
      url: "https://api.github.com/repos/bitovi/canjs/commits/1107f77cc5074b7ad9b7f628afb43bc703325111"
    }]
  },
  public: true,
  created_at: "2013-09-05T14:43:05Z",
  org: {
    id: 2782656,
    login: "bitovi",
    gravatar_id: "89162cee14c11672d134cfafed24d1be",
    url: "https://api.github.com/orgs/bitovi",
    avatar_url: "https://2.gravatar.com/avatar/89162cee14c11672d134cfafed24d1be?d=https%3A%2F%2Fa248.e.akamai.net%2Fassets.github.com%2Fimages%2Fgravatars%2Fgravatar-org-420.png"
  }
}
issue_source_data = {
  payload: {
    issue: {
      title: "Someone found a bug!",
      body: "The description",
      state: "closed",
      labels: [{name: "bug"}, {name: "question"}]
    }
  }
}

FactoryGirl.define do

  factory :props, class:Hash do
    feed "some_feed"
    category "some_category"
    tags ['some_feed','some_category','some_content_tag']
    origin_author_id "1"
    origin_author_username "some_user"

    initialize_with { attributes }
  end

  factory :event do
    title "Title"
    body "A body that has many many words in it."
    origin_date Date.today
    origin_ts Time.now
    sequence(:hash_key) {|n| Digest::MD5.hexdigest(title + body + n.to_s) }
    props FactoryGirl.build(:props)

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

    ### Twitter event

    factory :twitter_event do
      association :feed, factory: :tag, name: 'twitter'
      association :category, factory: :tag, name: 'twitter'
      tag_list ['twitter','status_event','canjs']

      trait :tweet do
        title "A hashtag #canjs and a @canjs mention."
      end

      trait :retweet do
        title "RT: A hashtag #canjs and a @canjs mention."
      end

      factory :twitter_tweet, traits: [:with_determined_rule, :tweet]
      factory :twitter_retweet, traits: [:with_determined_rule, :retweet]
    end

    ### Github event

    factory :github_event do
      association :feed, factory: :tag, name: 'github'
      with_determined_rule
        
      factory :github_issue do
        title "raised issue #1"
        association :category, factory: :tag, name: 'bug'
        tag_list %w(github issues_event issue canjs bug)
      
        trait :with_source_data do
          source_data(issue_source_data)
        end
      end

      factory :github_push do
        title "pushed commits"
        association :category, factory: :tag, name: "code"
        tag_list %w(github push_event code canjs)

        trait :with_push_event_source_data do
          source_data(push_event_source_data)
        end
      end

      factory :github_pull_request do
        title "requested a pull"
        association :category, factory: :tag, name: "code"
        tag_list %w(github pull_request_event code canjs)
      end

      factory :github_issue_comment do
        title "commented on issue #1"
        association :category, factory: :tag, name: "comment"
        tag_list %w(github issue_comment_event comment canjs)
        
        trait :with_source_data do
          source_data(issue_source_data)
        end
      end

      factory :github_commit_comment do
        title "commented on a commit 4b2342hh"
        association :category, factory: :tag, name: "comment"
        tag_list %w(github commit_comment_event comment canjs)
      end
    end
  end
end
