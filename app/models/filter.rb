class Filter < ActiveRecord::Base

  belongs_to :filterable, polymorphic: true
  has_many :natlang_queries, :dependent => :destroy

  validates_presence_of :is_conj, :classification
  validates_uniqueness_of :classification, scope: :filterable_id
  validate :classification_type
  validate :classification_filterable_combination

  def combined_queries
    QueryCombinator.new(self.natlang_queries.all, is_conj).combine
  end

  def all?
    is_conj
  end

  def any?
    not(is_conj)
  end
  
  def classification_filterable_combination
    if (classification == 'blocking' && filterable_type.match(/service/i))\
        || (classification == 'moderating' && filterable_type.match(/service/i))
        errors.add(:classification, 'blocking/moderating filter can only belong to an embed')
    elsif (classification == 'linking' && not(filterable_type.match(/service/i)))
      errors.add(:classification, 'linking filter can only belong to a service')
    end
  end

  def classification_type
    if classification != 'blocking' && classification != 'moderating' && classification != 'linking'
      errors.add(:classification, 'must be either "blocking", "moderating" or "linking"')
    end
  end

  def detects?
    true
  end
  alias_method :blocks?, :detects?
  alias_method :approves?, :detects?
  alias_method :links?, :detects?
end
