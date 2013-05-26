require 'factory_girl'

FactoryGirl.define do

  factory :actor do
    id 519262
    login "veljkodragsic"
    gravatar_id "703972d1c2861080f67e265c083cf81f"
    url "https://api.github.com/users/veljkodragsic"
    avatar_url ""
  end


  factory :organization do
    id 3448281
    login "bithub-test"
    gravatar_id "d41d8cd98f00b204e9800998ecf8427e"
    url "https://api.github.com/orgs/bithub-test"
    avatar_url ""
  end

  factory :repository do
    id 7957408,
    name "bithub-test/test-repo"
    url "https://api.github.com/repos/bithub-test/test-repo"
  end
  
  factory :user do
    login "veljkodragsic"
    id 519262
    avatar_url ""
    gravatar_id "703972d1c2861080f67e265c083cf81f"
    url "https://api.github.com/users/veljkodragsic"
    followers_url "https://api.github.com/users/veljkodragsic/followers"
    following_url "https://api.github.com/users/veljkodragsic/following"
    gists_url "https://api.github.com/users/veljkodragsic/gists{/gist_id}"
    starred_url "https://api.github.com/users/veljkodragsic/starred{/owner}{/repo}"
    subscriptions_url "https://api.github.com/users/veljkodragsic/subscriptions"
    organizations_url "https://api.github.com/users/veljkodragsic/orgs"
    repos_url "https://api.github.com/users/veljkodragsic/repos"
    events_url "https://api.github.com/users/veljkodragsic/events{/privacy}"
    received_events_url "https://api.github.com/users/veljkodragsic/received_events"
    type "User"
  end

  factory :event do
    id "1687001132"
    type "PushEvent"
    actor FactoryGirl.build(:actor)
    repo FactoryGirl.build(:repo)
    #payload
    public: true
    created_at: "2013-02-14T22:48:22Z"
    org FactoryGirl.build(:org)
  end

end
