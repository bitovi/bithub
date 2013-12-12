class Pagination < ActiveRecord::Base
  self.table_name = :pagination

  scope :by_category, lambda {|c| where(:category => c)}

  def self.grouped
    grouped = []
    
    self.order('"date" desc').each do |row|

      if grouped.last && (grouped.last[:date] == row.date)
        grouped.last[row.category] = row.cnt
      else
        grouped.push({:date => row.date, row.category.to_sym => row.cnt})
      end
    end

    grouped
  end

  def self.refresh
    ActiveRecord::Base.connection.execute("REFRESH MATERIALIZED VIEW \"#{self.table_name}\";")
  end
end
