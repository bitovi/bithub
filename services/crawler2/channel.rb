class Channel
  def initialize(brand_name, topics)
    @name = brand_name
    @topics = topics
  end
  attr_reader :name, :topics

  def match(object)
    # todo test object against followed topics
    true
  end
end
