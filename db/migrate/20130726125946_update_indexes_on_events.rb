class UpdateIndexesOnEvents < ActiveRecord::Migration
  def up
    remove_index(:events, :origin_date)
    add_index(:events, :thread_updated_date)
  end

  def down
    add_index(:events, :origin_date)
    remove_index(:events, :thread_updated_date)
  end
end
