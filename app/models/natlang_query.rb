class NatlangQuery < ActiveRecord::Base
  ::NatlangQueries::Translator # force auto-load
  
  before_save :format_val_for_contains

  belongs_to :filter
  validates_presence_of :val, :op
  validate :possible_ops

  def to_ar_query
    NatlangQueries::Translator.new(self).to_ar_query
  end

  def negated?
    is_negated
  end

  def clean
    self.val = val.gsub(/([^0-9a-z])+/i, ' ')
  end

  private

  def format_val_for_contains
    if %w(contains_any contains_all).include?(op)
      self.val = val.strip.gsub(/\s+/, ',')
    end
  end

  def possible_ops
    unless (ops = NatlangQueries::VALID_OPS).include? op
      errors.add :op, "must be one of #{ops.join(', ')}"
    end
  end
end
