class UserDecorator < Draper::Decorator
  delegate_all

  def roles
    source.roles.pluck(:name)
  end

  def score
    self.total_score
  end
  
end
