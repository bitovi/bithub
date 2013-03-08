FactoryGirl.define do

  factory :tag, :aliases => [:category, :feed] do
    initialize_with { Tag.find_by_name(name) || new({name: name}) } # should only initialize, not create, but this is ok for now
    name "a_tag"
    display_name "A tag"
  end

end
