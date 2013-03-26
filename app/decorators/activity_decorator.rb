class ActivityDecorator < Draper::Decorator
  delegate_all

  def type
    source.class.to_s.downcase
  end
end
