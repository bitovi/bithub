class AddIsProcessedToEvents < ActiveRecord::Migration
  def change
    change_table :events do |t|
      t.boolean :is_processed, default: false
    end
  end
end
