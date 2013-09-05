class Achievement < ActiveRecord::Base
  attr_accessible :note, :achieved_at, :shipped_at

  belongs_to :user
  belongs_to :reward

  after_initialize :init

  def init
    self.achieved_at = Time.now()
  end

end
