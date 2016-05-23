class Histogram < ActiveRecord::Base
  VALID_RESOLUTIONS = %w(minute hour day week month)

  belongs_to :source, polymorphic: true

  self.table_name = 'histogram'
  self.primary_key = :measured_at

  def self.stats_by_source_type(source_type, resolution)
    fail ArgumentError.new("resolution must be one of #{VALID_RESOLUTIONS.join(', ')}") if !VALID_RESOLUTIONS.include? resolution

    Histogram\
      .select("source_id, max(volume) as volume, sum(delta) as delta, date_trunc('#{resolution}', measured_at) as measured_at")
      .group("source_id, date_trunc('#{resolution}', measured_at)")
      .order("source_id, date_trunc('#{resolution}', measured_at) asc")
      .where("source_type" => source_type)
  end

  def self.fill_stats(recurrence = 'minute')
    fill_service_stats(recurrence)
    fill_hub_stats(recurrence)
  end
  
  def self.fill_service_stats(recurrence = 'minute')
    ActiveRecord::Base.connection.execute <<-SQL
      insert into histogram (source_type, source_id, volume, delta, measured_at)
      with whole as (
        select services.id as source_id
               , sum(case when bits.id is not null then 1 else 0 end) as volume
               , date_trunc('#{recurrence}', now()) as measured_at
        from services
        left join service_bits on services.id = service_bits.service_id
        left join bits on service_bits.bit_id = bits.id
        group by services.id
        union (
          select source_id, volume, measured_at
          from histogram
          where source_type = 'Service'
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
      ) select 'Service' source_type
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

  def self.fill_hub_stats(recurrence = 'minute')
    ActiveRecord::Base.connection.execute <<-SQL
      insert into histogram (source_type, source_id, volume, delta, measured_at)
      with whole as (
        select hubs.id as source_id
               , sum(case when bits.id is not null then 1 else 0 end) as volume
               , date_trunc('#{recurrence}', now()) as measured_at
        from hubs
        left join moderations on hubs.id = moderations.hub_id
        left join bits on moderations.bit_id = bits.id
        group by hubs.id
        union (
          select source_id, volume, measured_at
          from histogram
          where source_type = 'Hub'
          order by measured_at desc
          limit (select count (distinct (hubs.id)) from hubs))
        order by source_id, measured_at asc
      ), whole_diffed as (
        select source_id
             , volume
             , (volume - lag(volume::int,1,0) over w) as delta
             , measured_at
        from whole
        window w as (partition by source_id order by measured_at asc)
      ) select 'Hub' source_type
           , source_id
           , volume
           , delta
           , measured_at
      from whole_diffed
      where (now() - measured_at) < '1 #{recurrence}'::interval;
    SQL
  rescue ActiveRecord::RecordNotUnique => e
    Rails.logger.error "Histogram hub data should be filled only once each #{recurrence}"
    nil
  end
end
