class CreateEntitiesServices < ActiveRecord::Migration
  def change
    create_table :entities_services, id: false do |t|
      t.references :service
      t.references :entity
    end
    add_index :entities_services, [:entity_id, :service_id]
    add_index :entities_services, :service_id
  end
end
