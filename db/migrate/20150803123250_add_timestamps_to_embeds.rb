class AddTimestampsToEmbeds < ActiveRecord::Migration
  def change
    change_table :embeds do |t|
      t.timestamps
    end
  end
end
