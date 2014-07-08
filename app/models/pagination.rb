class Pagination < ActiveRecord::Base
  self.table_name = :pagination

  def self.grouped(args)
    tags   = args[:tags]     || []
    funnel = args[:funnel]
    limit  = args[:limit]    || 30
    offset = args[:offset]   || 0
    tz     = args[:clientTz] || "UTC"
    order  = (args[:order]   || "DESC").to_s.upcase

    order  = order === "ASC" ? "ASC" : "DESC"

    future = args[:only_future].present?

    query = ["SELECT p.date, hstore(array_agg(p.funnel)::text[], array_agg(p.cnt)::text[]) AS counts FROM
               (SELECT (ts AT TIME ZONE 'UTC' AT TIME ZONE $1)::date AS date, CASE WHEN funnel IS NULL THEN 'unknown' ELSE funnel END, COUNT(*) AS cnt
                  FROM pagination AS p
                  WHERE $2 <@ tags AND (funnel = $3 OR $3 IS NULL)
                  GROUP BY date, funnel
                  ORDER BY date DESC) AS p",
               (future ? "WHERE p.date > $4" : "WHERE 1 = $4"),
               "GROUP BY p.date ORDER BY p.date", order,
               "LIMIT $5 OFFSET $6;"].join(' ')

    results = ActiveRecord::Base.connection.raw_connection.exec_params(query, [
      tz,
      "{#{tags.join(",")}}",
      funnel,
      (future ? ActiveSupport::TimeZone[tz].at(Time.now).to_date - 1.day : 1),
      limit,
      offset
    ])

    results.map do |row|
      {'date' => row['date']}.merge Hash[ from_hstore(row['counts']).map {|k,v| [k,v.to_i]} ]
    end
  end

  def self.refresh
    ActiveRecord::Base.connection.execute("REFRESH MATERIALIZED VIEW \"#{self.table_name}\";")
  end

  private

  def self.from_hstore str
    HstoreDeserializer.new(str).parse
  end

  class HstoreDeserializer
    include ActiveRecord::ConnectionAdapters::PostgreSQLColumn::Cast
    def initialize(str)
      @str = str
    end

    def parse
      string_to_hstore(@str)
    end
  end

end
