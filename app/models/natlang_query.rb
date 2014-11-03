class NatlangQuery < ActiveRecord::Base
  ::NatlangQueries::Translator # force auto-load

  belongs_to :filter
  validates_presence_of :val, :op
  validate :possible_verbs

  def to_ar_query
    NatlangQueries::Translator.new(self).to_ar_query
  end

  def negated?
    is_negated
  end

  def possible_verbs
    unless (verbs = NatlangQueries::POSSIBLE_VERBS).include? op
      errors.add(:op, "must be one of #{verbs.join(', ')}")
    end
  end
end
