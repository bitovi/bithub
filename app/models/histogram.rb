class Histogram < ActiveRecord::Base
  VALID_RESOLUTIONS = %w(minute hour day week month)
  VALID_TYPES = %w(embeds services users)

  validates_presence_of :source_type, :source_id
  validate :source_type_is_of_valid_type

  self.table_name = 'histogram'
  self.primary_key = :measured_at

  def self.stats_by_source_type(source_type, resolution)
    fail ArgumentError.new("resolution must be one of #{VALID_RESOLUTIONS.join(', ')}") if !VALID_RESOLUTIONS.include? resolution
    fail ArgumentError.new("type must be one of #{VALID_TYPES.join(', ')}") if !VALID_TYPES.include? source_type

    Histogram\
      .select("source_id, max(volume) as volume, sum(delta) as delta, date_trunc('#{resolution}', measured_at) as measured_at")
      .group("source_id, date_trunc('#{resolution}', measured_at)")
      .order("source_id, date_trunc('#{resolution}', measured_at) asc")
      .where("source_type" => source_type)
  end

  def self.fill_stats(recurrence = 'minute')
    fill_service_stats(recurrence)
    fill_embed_stats(recurrence)
  end
  
  def self.fill_service_stats(recurrence = 'minute')
    ActiveRecord::Base.connection.execute <<-SQL
      insert into histogram (source_type, source_id, volume, delta, measured_at)
      with whole as (
        select services.id as source_id
               , sum(case when entities.id is not null then 1 else 0 end) as volume
               , date_trunc('#{recurrence}', now()) as measured_at
        from services
        left join service_entities on services.id = service_entities.service_id
        left join entities on service_entities.entity_id = entities.id
        group by services.id
        union (
          select source_id, volume, measured_at
          from histogram
          where source_type = 'services'
          order by measured_at desc
          limit (select count (distinct (services.id)) from services))
        order by source_id, measured_at asc
      ), whole_diffed as (
        select source_id
             , volume
             , (volume - lag(volume::int,1,0) over w) as delta
             , measured_at
        from whole
        window w as (partition by source_id order by measured_at asc)
      ) select 'services' source_type
           , source_id
           , volume
           , delta
           , measured_at
      from whole_diffed
      where (now() - measured_at) < '1 #{recurrence}'::interval;
    SQL
  rescue ActiveRecord::RecordNotUnique => e
    Rails.logger.error "Histogram service data should be filled only once each #{recurrence}"
    nil
  end

  def self.fill_embed_stats(recurrence = 'minute')
    ActiveRecord::Base.connection.execute <<-SQL
      insert into histogram (source_type, source_id, volume, delta, measured_at)
      with whole as (
        select embeds.id as source_id
               , sum(case when entities.id is not null then 1 else 0 end) as volume
               , date_trunc('#{recurrence}', now()) as measured_at
        from embeds
        left join embed_entities on embeds.id = embed_entities.embed_id
        left join entities on embed_entities.entity_id = entities.id
        group by embeds.id
        union (
          select source_id, volume, measured_at
          from histogram
          where source_type = 'embeds'
          order by measured_at desc
          limit (select count (distinct (embeds.id)) from embeds))
        order by source_id, measured_at asc
      ), whole_diffed as (
        select source_id
             , volume
             , (volume - lag(volume::int,1,0) over w) as delta
             , measured_at
        from whole
        window w as (partition by source_id order by measured_at asc)
      ) select 'embeds' source_type
           , source_id
           , volume
           , delta
           , measured_at
      from whole_diffed
      where (now() - measured_at) < '1 #{recurrence}'::interval;
    SQL
  rescue ActiveRecord::RecordNotUnique => e
    Rails.logger.error "Histogram embed data should be filled only once each #{recurrence}"
    nil
  end

  def source_type_is_of_valid_type
    unless VALID_TYPES.include?(source_type)
      errors.add(:source_type, "must by one of #{VALID_TYPES.join(', ')}")
    end
  end
end
