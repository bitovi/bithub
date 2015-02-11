class Filter < ActiveRecord::Base

  belongs_to :embed
  has_many :natlang_queries, :dependent => :destroy

  validates_presence_of :classification #, :is_conj ? acts weird
  validates_uniqueness_of :classification, scope: :embed_id
  validate :classification_type

  def combined_queries
    NatlangQueries::Combinator.new(natlang_queries.all, is_conj).combine
  end

  def all?
    is_conj
  end

  def any?
    not(is_conj)
  end

  def classification_type
    if (classification != 'blocking' && classification != 'approving')
      errors.add(:classification, 'must be either "blocking", "approving"')
    end
  end

  def detects?
    true # TODO
  end

  alias_method :blocks?, :detects?
  alias_method :approves?, :detects?
end
