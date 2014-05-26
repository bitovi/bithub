FactoryGirl.define do

  factory :funnel do

    name "example"
    display_name "A nice example"

    feed_name "github"
    type_name "issue"

    tags %w(bug canjs)

  end

end
