class AddThreadUpdatedDateToEvents < ActiveRecord::Migration
  def change
    add_column :events, :thread_updated_date, :date
  end
end
