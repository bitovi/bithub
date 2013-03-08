FactoryGirl.define do

  factory :tag, :aliases => [:category, :feed] do
    initialize_with { Tag.find_or_create_with_like_by_name(name)}
    name "a_tag"
    display_name "A tag"
  end

end
