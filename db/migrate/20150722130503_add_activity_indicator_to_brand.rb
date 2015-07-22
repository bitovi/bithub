class AddActivityIndicatorToBrand < ActiveRecord::Migration
  def up
    if Apartment::Tenant.current == 'public'
      add_column :brands, :is_active, :boolean, default: true
    end
  end

  def down
    if Apartment::Tenant.current == 'public'
      remove_column :brands, :is_active
    end
  end
end
