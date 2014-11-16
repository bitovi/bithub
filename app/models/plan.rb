class Plan < ActiveRecord::Base

  scope :stripe_ids, -> { pluck :stripe_id }

  def self.valid_stripe_id(stripe_id)
    stripe_ids.include? stripe_id.to_s
  end
end
