class RenameEntityServiceJoinTable < ActiveRecord::Migration
  def change
    rename_table :entities_services, :service_entities
    add_column :service_entities, :id, :primary_key
  end
end
