class AddServiceIdToEvents < ActiveRecord::Migration
  def change
    change_table :events do |t|
      t.references :service
    end
  end
end
