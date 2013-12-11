class Pagination < ActiveRecord::Base
  self.table_name = :pagination

  scope :by_category, lambda {|c| where(:category => c)}

  def self.grouped
    grouped = {}
    
    self.order('"date" desc').each do |row|
      grouped[row.date] = Hash.new(0) unless grouped[row.date]
      grouped[row.date][row.category] += row.cnt
    end

    grouped
  end

  def self.refresh
    ActiveRecord::Base.connection.execute("REFRESH MATERIALIZED VIEW \"#{self.table_name}\";")
  end
end
