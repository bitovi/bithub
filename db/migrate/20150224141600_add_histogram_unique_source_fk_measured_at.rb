class AddHistogramUniqueSourceFkMeasuredAt < ActiveRecord::Migration
  def up
    execute "ALTER TABLE histogram ADD CONSTRAINT histogram_unique_source_fk_measured_at UNIQUE (source_type, source_fk, measured_at);" 
  end

  def down
    execute "ALTER TABLE histogram DROP CONSTRAINT histogram_unique_source_fk_measured_at;"
  end
end
