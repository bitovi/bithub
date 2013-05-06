class ActivityDecorator < Draper::Decorator
  delegate_all

  def type
    source.respond_to?(:authorship_value) ? "authored" : source.class.to_s.downcase
  end

  def title
    source.respond_to?(:title) ? source.title : source.comment
  end

  def value
    source.respond_to?(:value) ? source.value : source.authorship_value
  end
end
