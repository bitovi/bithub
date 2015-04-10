class NatlangQuery < ActiveRecord::Base
  ::NatlangQueries::Translator # force auto-load

  belongs_to :filter
  validates_presence_of :val, :op
  validate :possible_ops

  def to_ar_query
    NatlangQueries::Translator.new(self).to_ar_query
  end

  def negated?
    is_negated
  end

  private

  def possible_ops
    unless (ops = NatlangQueries::VALID_OPS).include? op
      errors.add :op, "must be one of #{ops.join(', ')}"
    end
  end
end
