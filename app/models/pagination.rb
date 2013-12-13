class Pagination < ActiveRecord::Base
  self.table_name = :pagination

  def self.grouped(tags = nil)
    tags = tags.is_a?(Array) ? tags : []

    query = "SELECT p.date, hstore(array_agg(p.category)::text[], array_agg(p.cnt)::text[]) AS counts FROM 
               (SELECT ts::date AS date, category, COUNT(*) AS cnt 
                  FROM pagination AS p 
                  WHERE #{tags.to_postgres_array} <@ tags 
                  GROUP BY date, category
                  ORDER BY date DESC) AS p
               GROUP BY p.date
               ORDER BY p.date DESC
               LIMIT 20 OFFSET 0;"

    ActiveRecord::Base.connection.execute(query).map do |row|
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
