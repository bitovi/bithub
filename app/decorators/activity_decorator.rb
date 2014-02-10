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

  def upvotes
    source[:upvotes] || nil
  end

  def created_at
    Rails.logger.info source.inspect
    source[:origin_ts] || source[:created_at]
  end

  def actor
    if source.instance_of? Event
      source.author ? source.author : nil
    else
      source.actor
    end
  end

  def applies_to
    if source.instance_of? Event
      source
    else
      source.applies_to
    end
  end
end
