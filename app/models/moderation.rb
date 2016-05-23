class Moderation < ActiveRecord::Base
  DECISIONS = ['approved', 'deleted', 'pending', 'starred'] 
  
  belongs_to :hub
  belongs_to :bit
  
  validates_uniqueness_of :hub_id, scope: [:bit_id]

  def is_approved
    (read_attribute(:is_approved_manually) != nil) ? is_approved_manually? : is_approved_automatically?
  end

  def approve
    returning(update_attribute(:is_approved_manually, true)) do
      bit.touch
      Notifier.notify_client(:bit_moderated, { bit: bit, action: 'approved' })
    end
  end

  def block
    returning(update_attributes({is_approved_manually: false, is_pinned: false})) do
      bit.touch
      Notifier.notify_client(:bit_moderated, { bit: bit, action: 'blocked' })
    end
  end
  alias_method :disapprove, :block

  def pin
    returning(update_attributes({is_pinned: true, is_approved_manually: true})) do
      bit.touch
      Notifier.notify_client(:bit_moderated, { bit: bit, action: 'approved' })
    end
  end

  def unpin
    returning(update_attribute(:is_pinned, false)) do
      bit.touch
      Notifier.notify_client(:bit_moderated, { bit: bit })
    end
  end

  def decide(decision)
    returning(update_attribute(:decision, decision)) do
      bit.touch
      Notifier.notify_client(:bit_moderated, { bit: bit })
    end
  end

  private
  def returning(exp)
    yield(exp)
    exp
  end
end
