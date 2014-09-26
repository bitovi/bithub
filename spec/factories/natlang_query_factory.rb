FactoryGirl.define do

  factory :natlang_query do
    attr "content"
    op "contains"
    val "some bug"
  end

end
