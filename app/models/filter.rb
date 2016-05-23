class Filter < ActiveRecord::Base

  belongs_to :hub
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

  # "true" represents filter pass
  # "false represents filter reject
  def resulting_state
    approves?
  end

  # used for inbox-style moderation
  def resulting_decision
    (approves?) ? 'approved' : 'deleted'
  end

  def detected(select_values = nil)
    NatlangQueries::Applier.new(self, Bit).scope(select_values).all
  end
  alias_method :detected_bits, :detected

  def detects?(bit)
    NatlangQueries::Applier.new(self, Bit).scope.where(id: bit.id).first
  end

  private

  def validate_action_value
    unless VALID_ACTIONS.include? action
      errors.add :action, "must be one of #{VALID_ACTIONS.join(', ')}"
    end
  end

end
