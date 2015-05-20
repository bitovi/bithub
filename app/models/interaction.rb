class Interaction < ActiveRecord::Base
  VALID_RESOLUTIONS = %w(minute hour day week month)
  VALID_TYPES = %w(embeds cards)

  validates_presence_of :source_type, :source_id
  validate :source_type_is_of_valid_type
  
  self.primary_key = :created_at

  def self.stats(resolution, source_type = nil, source_id = nil)
    fail ArgumentError.new("resolution must be one of #{VALID_RESOLUTIONS.join(', ')}") if !VALID_RESOLUTIONS.include?(resolution)

    if source_type && !VALID_TYPES.include?(source_type)
      fail ArgumentError.new("source_type must be one of #{VALID_TYPES.join(', ')}")
    end

    query = Interaction\
      .select(select_statement(resolution, source_type, source_id))
      .group(group_statement(resolution, source_type, source_id))
      .order(order_statement(resolution))

    if source_type
      query = query.where(source_type: source_type)
    end

    query
  end

  def self.select_statement(resolution, source_type = nil, source_id = nil)
    statement = ""
    statement += "date_trunc('#{resolution}', created_at) as created_at"
    statement += ', source_type' if source_type
    statement += ', source_id' if source_id
    statement += ', event_type'
    statement += ', count(*) as volume'
    statement
  end

  def self.group_statement(resolution, source_type = nil, source_id = nil)
    statement = ""
    statement += "date_trunc('#{resolution}', created_at)"
    statement += ', source_type' if source_type
    statement += ', source_id' if source_id
    statement += ', event_type'
    statement
  end

  def self.order_statement(resolution)
    statement = "date_trunc('#{resolution}', created_at) asc"
  end
  
  def source_type_is_of_valid_type
    unless VALID_TYPES.include?(source_type)
      errors.add(:source_type, "must by one of #{VALID_TYPES.join(', ')}")
    end
  end
end
