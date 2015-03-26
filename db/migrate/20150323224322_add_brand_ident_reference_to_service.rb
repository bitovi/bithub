class AddBrandIdentReferenceToService < ActiveRecord::Migration
  def change
    change_table :services do |t|
      t.references :brand_identity \
      unless column_exists? 'public.services', 'brand_identity_id'
    end
  end
end
