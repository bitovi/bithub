class Channel
  def initialize(brand_name, topics)
    @name = brand_name
    @topics = topics
  end
  attr_reader :name, :topics

  def interested?(object, attrs)
    @topics.reduce(false) { |mem, topic| mem || not(target_text(object, attrs).scan(topic).empty?) }
  end

  def target_text(object, attrs)
    attrs.reduce("") do |acc, attr|
      if object.respond_to? attr
        acc + object.send(attr)
      else
        acc + object.fetch(attr)
      end
    end
  end
end
