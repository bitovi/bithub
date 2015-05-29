class DeleteHistogramCheckDeltaGtZero < ActiveRecord::Migration
  def up
    execute "ALTER TABLE histogram DROP CONSTRAINT histogram_delta_gte_zero;"
  end

  def down
    execute "ALTER TABLE histogram ADD CONSTRAINT histogram_delta_gte_zero CHECK (delta >= 0);"
  end
end
