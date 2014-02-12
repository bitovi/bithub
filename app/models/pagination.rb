class Pagination < ActiveRecord::Base
  self.table_name = :pagination

  def self.grouped(args)
    tags   = args[:tags]     || []
    limit  = args[:limit]    || 30
    offset = args[:offset]   || 0
    tz     = args[:clientTz] || "UTC"
    order  = (args[:order]   || "DESC").to_s.upcase

    order  = order === "ASC" ? "ASC" : "DESC"

    future = args[:only_future].present?

    query = ["SELECT p.date, hstore(array_agg(p.category)::text[], array_agg(p.cnt)::text[]) AS counts FROM 
               (SELECT (ts AT TIME ZONE 'UTC' AT TIME ZONE $1)::date AS date, category, COUNT(*) AS cnt 
                  FROM pagination AS p 
                  WHERE $2 <@ tags 
                  GROUP BY date, category
                  ORDER BY date DESC) AS p",
               (future ? "WHERE p.date > $3" : "WHERE 1 = $3"),
               "GROUP BY p.date ORDER BY p.date", order,
               "LIMIT $4 OFFSET $5;"].join(' ')

    results = ActiveRecord::Base.connection.raw_connection.exec_params(query, [
      tz, 
      "{#{tags.join(",")}}", 
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
    ActiveRecord::Coders::Hstore.load(str)
  end
  
end
