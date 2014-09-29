class EmbedFilter < ActiveRecord::Base
  belongs_to :embed
  belongs_to :filter

  validates_uniqueness_of :classification, :scope => [:filter_id]
  validate :classification_must_be_either_blocking_or_moderating

  def classification_must_be_either_blocking_or_moderating
    if classification != 'blocking' && classification != 'moderating'
      errors.add(:classification, 'must be either "blocking" or "moderating"')
    end
  end
end

