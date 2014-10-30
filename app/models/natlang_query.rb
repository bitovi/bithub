class NatlangQuery < ActiveRecord::Base

  belongs_to :filter
  validates_presence_of :val, :op

  def to_ar_query
    NatlangQueries::Translator.new(self).to_ar_query
  end

  def negated?
    is_negated
  end
end
