class Filter < ActiveRecord::Base

  belongs_to :embed
  has_many :natlang_queries, :dependent => :destroy

  validates_presence_of :is_conj, :classification
  validates_uniqueness_of :classification, scope: :embed_id
  validate :classification_must_be_either_blocking_or_moderating

  def combined_queries
    QueryCombinator.new(self.natlang_queries.all, is_conj).combine
  end

  def all?
    is_conj
  end

  def any?
    not(is_conj)
  end

  def classification_must_be_either_blocking_or_moderating
    if classification != 'blocking' && classification != 'moderating'
      errors.add(:classification, 'must be either "blocking" or "moderating"')
    end
  end
end
