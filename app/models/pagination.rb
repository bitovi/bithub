class Pagination < ActiveRecord::Base
  self.table_name = :pagination

  def self.grouped(tags = nil)
    grouped = []
    tags = tags.is_a?(Array) ? tags : []
    
    self
      .select("date, category, COUNT(*) AS cnt")
      .where("#{tags.to_postgres_array} <@ tags")
      .group("date, category")
      .order("\"date\" DESC")
      .each do |row|
      
      if grouped.last && (grouped.last[:date] == row.date)
        grouped.last[row.category] = row.cnt
      else
        grouped.push({:date => row.date, row.category.to_sym => row.cnt })
      end
    end

    grouped
  end

  def self.refresh
    ActiveRecord::Base.connection.execute("REFRESH MATERIALIZED VIEW \"#{self.table_name}\";")
  end
end

