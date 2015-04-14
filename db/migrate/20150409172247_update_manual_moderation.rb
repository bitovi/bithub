class UpdateManualModeration < ActiveRecord::Migration

  def up
    Brand.pluck(:name).each do |n|
      Apartment::Tenant.switch(n) do
        EmbedEntity.where(is_approved_manually: nil).update_all(is_approved_manually: false)
      end
    end

    change_column_default :embed_entities, :is_approved_manually, false
    change_column_null :embed_entities, :is_approved_manually, false

  end
  
  def down
    change_column_default :embed_entities, :is_approved_manually, nil
    change_column_null :embed_entities, :is_approved_manually, true
  end
end
