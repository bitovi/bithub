class Interaction < ActiveRecord::Base
  VALID_RESOLUTIONS = %w(minute hour day week month)
  
  belongs_to :primary_source, polymorphic: true
  belongs_to :secondary_source, polymorphic: true

  validates_presence_of :primary_source, :event_type
  
  self.primary_key = :created_at

  def self.stats(resolution, zoom = 'detailed', filter = {})
    fail ArgumentError.new("resolution must be one of #{VALID_RESOLUTIONS.join(', ')}") if !VALID_RESOLUTIONS.include?(resolution)

    query = Interaction\
      .select(select_statement(resolution, zoom))
      .group(group_statement(resolution, zoom))
      .order(order_statement(resolution))

    if !filter.empty?
      query = query.where(filter)
    end

    query
  end

  def self.select_statement(resolution, zoom = 'detailed')
    if zoom == 'detailed'
      "date_trunc('#{resolution}', created_at) as created_at, primary_source_type, primary_source_id, event_type, event_subtype, count(*) as volume"
    elsif zoom == 'rough'
      "date_trunc('#{resolution}', created_at) as created_at, primary_source_type, primary_source_id, event_type, count(*) as volume"
    end
  end

  def self.group_statement(resolution, zoom = 'detailed')
    if zoom == 'detailed'
      "date_trunc('#{resolution}', created_at), primary_source_type, primary_source_id, event_type, event_subtype"
    elsif zoom == 'rough'
      "date_trunc('#{resolution}', created_at), primary_source_type, primary_source_id, event_type"
    end
  end

  def self.order_statement(resolution)
    statement = "date_trunc('#{resolution}', created_at) asc"
  end
end
