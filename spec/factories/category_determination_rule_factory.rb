FactoryGirl.define do

  factory :category_determination_rule do
    name "foobarbaz"
    required_tags({
      "foo" => 1,
      "bar" => 1,
      "baz" => 1
    })
  end

end
