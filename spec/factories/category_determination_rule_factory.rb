FactoryGirl.define do

  factory :category_determination_rule do
    name "foobarbaz"
    scorings({
      "foo" => 1,
      "bar" => 1,
      "baz" => 1
    })
  end

end
