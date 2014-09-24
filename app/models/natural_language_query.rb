class NaturalLanguageQuery < ActiveRecord::Base

  has_and_belongs_to_many :filters
  validates_presence_of :val, :op

  def to_ar_query
    NaturalLanguageQueryTranslator.new(self).to_ar_query
  end

end
