class Filter < ActiveRecord::Base

  belongs_to :embed
  has_many :natlang_queries, :dependent => :destroy

  VALID_ACTIONS = %w(approve block)

  validate :validate_action_value

  def self.sorted_in_application_order
    order("(case when action = 'approve' then 1 when action = 'block' then 2 end)")
  end

  def combined_queries
    natlang_queries.all.map do |q|
      q.to_ar_query
    end
  end

  def blocks?
    action == 'block'
  end

  def approves?
    action == 'approve'
  end
  alias_method :resulting_state, :'approves?'

  def detected(select_values = nil)
    NatlangQueries::Applier.new(self, Entity).scope(select_values).all
  end
  alias_method :detected_entities, :detected

  def detects?(entity)
    NatlangQueries::Applier.new(self, Entity).scope.where(id: entity.id).first
  end

  private

  def validate_action_value
    unless VALID_ACTIONS.include? action
      errors.add :action, "must be one of #{VALID_ACTIONS.join(', ')}"
    end
  end

end
