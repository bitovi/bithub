class AddHistogramCheckVolumeDeltaGtZero < ActiveRecord::Migration
  def up
    execute "ALTER TABLE histogram ADD CONSTRAINT histogram_volume_gte_zero CHECK (volume >= 0);" 
    execute "ALTER TABLE histogram ADD CONSTRAINT histogram_delta_gte_zero CHECK (delta >= 0);" 
  end

  def down 
    execute "ALTER TABLE histogram DROP CONSTRAINT histogram_volume_gte_zero;"
    execute "ALTER TABLE histogram DROP CONSTRAINT histogram_delta_gte_zero;"
  end
end
