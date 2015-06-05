class CreateEmbedEvents < ActiveRecord::Migration
  def change
    create_table :embed_events do |t|
      t.references :organization
      t.references :brand
      t.references :embed

      t.string :organization_name
      t.string :brand_name
      t.string :embed_name

      t.string :action
      t.string :attr, default: ''
      t.string :old_value, default: ''
      t.string :new_value, default: ''

      t.timestamps
    end if Apartment::Tenant.current == 'public'

    add_column :embeds, :published, :boolean, default: false
  end
end
