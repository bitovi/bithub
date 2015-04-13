class UpdateModeration < ActiveRecord::Migration
  def change
    remove_column :filters, :is_conj
    remove_column :filters, :classification
    add_column    :filters, :action, :string, null: false

    add_column            :embed_entities, :is_approved_automatically, :boolean
    rename_column         :embed_entities, :is_approved, :is_approved_manually
  end
end
