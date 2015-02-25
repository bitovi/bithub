class Histogram < ActiveRecord::Base
  VALID_SOURCE_TYPES = %w(embeds services users)
  VALID_RESOLUTIONS = %w(minute hour day week month)

  self.table_name = 'histogram'
  self.primary_key = :source_id
  
  def self.stats_by_source_type(source_type, resolution)
    fail ArgumentError.new("source_type must be one of #{VALID_SOURCE_TYPES.join(', ')}") if !VALID_SOURCE_TYPES.include? source_type
    fail ArgumentError.new("resolution must be one of #{VALID_RESOLUTIONS.join(', ')}") if !VALID_RESOLUTIONS.include? resolution

    Histogram\
      .select("source_fk as source_id, max(volume) as volume, sum(delta) as delta, date_trunc('#{resolution}', measured_at) as measured_at")
      .group("source_fk, date_trunc('#{resolution}', measured_at)")
      .order("source_fk, date_trunc('#{resolution}', measured_at) asc")
      .where("source_type" => source_type)
  end

  def self.fill_stats(recurrence = 'minute')
    fill_service_stats(recurrence)
    fill_embed_stats(recurrence)
  end
  
  def self.fill_service_stats(recurrence)
    ActiveRecord::Base.connection.execute <<-SQL
      insert into histogram (source_type, source_fk, volume, delta, measured_at)
      with whole as (
        select services.id as source_fk
               , sum(case when entities.id is not null then 1 else 0 end) as volume
               , date_trunc('#{recurrence}', now()) as measured_at
        from services
        left join service_entities on services.id = service_entities.service_id
        left join entities on service_entities.entity_id = entities.id
        group by services.id
        union (
          select source_fk, volume, measured_at
          from histogram
          where source_type = 'services'
          order by measured_at desc
          limit (select count (distinct (services.id)) from services))
        order by source_fk, measured_at asc
      ), whole_diffed as (
        select source_fk
             , volume
             , (volume - lag(volume::int,1,0) over w) as delta
             , measured_at
        from whole
        window w as (partition by source_fk order by measured_at asc)
      ) select 'services' source_type
           , source_fk
           , volume
           , delta
           , measured_at
      from whole_diffed
      where (now() - measured_at) < '1 #{recurrence}'::interval;
    SQL
  end

  def self.fill_embed_stats(recurrence)
    ActiveRecord::Base.connection.execute <<-SQL
      insert into histogram (source_type, source_fk, volume, delta, measured_at)
      with whole as (
        select embeds.id as source_fk
               , sum(case when entities.id is not null then 1 else 0 end) as volume
               , date_trunc('#{recurrence}', now()) as measured_at
        from embeds
        left join embed_entities on embeds.id = embed_entities.embed_id
        left join entities on embed_entities.entity_id = entities.id
        group by embeds.id
        union (
          select source_fk, volume, measured_at
          from histogram
          where source_type = 'embeds'
          order by measured_at desc
          limit (select count (distinct (embeds.id)) from embeds))
        order by source_fk, measured_at asc
      ), whole_diffed as (
        select source_fk
             , volume
             , (volume - lag(volume::int,1,0) over w) as delta
             , measured_at
        from whole
        window w as (partition by source_fk order by measured_at asc)
      ) select 'embeds' source_type
           , source_fk
           , volume
           , delta
           , measured_at
      from whole_diffed
      where (now() - measured_at) < '1 #{recurrence}'::interval;
    SQL
  end
end
