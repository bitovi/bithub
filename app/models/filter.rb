class Filter < ActiveRecord::Base

  belongs_to :embed
  has_many :natlang_queries, :dependent => :destroy

  VALID_ACTIONS = %w(approve block)

  validate :validate_action_value

  def combined_queries
    NatlangQueries::Combinator.new(natlang_queries.all).combine
  end

  def blocks?
    action == 'block'
  end

  def approves?
    action == 'approve'
  end

  def apply(entity)
    NatlangQueries::Applier.new(self, Entity).scope.where(id: entity.id).first
  end

  private

  def validate_action_value
    unless VALID_ACTIONS.include? action
      errors.add :action, "must be one of #{VALID_ACTIONS.join(', ')}"
    end
  end

end
