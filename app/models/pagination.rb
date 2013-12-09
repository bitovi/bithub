class Pagination < ActiveRecord::Base
  self.table_name = :pagination

  scope :by_category, lambda {|c| where(:category => c)}


  def self.grouped_db
    select_command = <<-SQL
      "date",
      (select coalesce(sum(cnt),0) from pagination ip where ip.category = 'chat' and ip."date" = pagination."date")::int as chat,
      (select coalesce(sum(cnt),0) from pagination ip where ip.category = 'digest' and ip."date" = pagination."date")::int as digest,
      (select coalesce(sum(cnt),0) from pagination ip where ip.category <> 'digest' and ip.category <> 'chat' and ip."date" = pagination."date")::int as other
    SQL

    self.select(select_command).group("\"date\"").order("\"date\" desc")
  end
  
  def self.grouped
    grouped_rows = {}
    self.all.each do |row|
      type = row.category.to_sym

      if grouped_rows[row.date].nil?
        grouped_rows[row.date] = {chat: 0, digest: 0, other: 0}
      end

      if type == :chat
        grouped_rows[row.date][:chat] += row.cnt
      elsif type == :digest
        grouped_rows[row.date][:digest] += row.cnt
      else
        grouped_rows[row.date][:other] += row.cnt
      end
    end

    grouped_rows
  end

  def self.refresh
    ActiveRecord::Base.connection.execute("REFRESH MATERIALIZED VIEW \"#{self.table_name}\";")
  end
end
