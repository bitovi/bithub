class AddEmbedIdToEvents < ActiveRecord::Migration
  def change
    change_table :events do |t|
      t.references :embed
    end
  end
end
