FactoryGirl.define do

  factory :event do
    title "Some title"
    body "And a body"
    date Date.today
    raw_json "{}"

    category
    feed
    tags {
      Array(3..7).sample.times.map do
        FactoryGirl.create(:tag)
      end
    }
  end

end
