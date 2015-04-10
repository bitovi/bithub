class EmbedEntity < ActiveRecord::Base
  belongs_to :embed
  belongs_to :entity

  scope :approved, lambda { where(is_approved: true) }
  scope :waitlisted, lambda { where(is_approved: false) }

  def approve
    update_attribute(:is_approved, true)
    entity.touch
  end

  def block
    update_attributes({is_approved: false, is_pinned: false})
    entity.touch
  end
  alias_method :disapprove, :block

  def pin
    update_attributes({is_pinned: true, is_approved: true})
    entity.touch
  end

  def unpin
    update_attribute(:is_pinned, false)
    entity.touch
  end

  def disconnect
    destroy
  end

  def determine_state
    state = !!embed.approving?

    filters = embed.filters.order("order by (case when action = 'approve' then 1 when action = 'block' then 2 end)")

    filters.reduce(state) do |s,f|
      s = !!f.approves? if f.apply(entity)
      s
    end

    ### TODO: persist state!!!
  end

end
