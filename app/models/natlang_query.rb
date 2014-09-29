class NatlangQuery < ActiveRecord::Base

  belongs_to :filter
  validates_presence_of :val, :op

  def to_ar_query
    NatlangQueryTranslator.new(self).to_ar_query
  end

end
