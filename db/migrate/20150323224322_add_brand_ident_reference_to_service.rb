class AddBrandIdentReferenceToService < ActiveRecord::Migration
  def change
    change_table :services do |t|
      t.references :brand_identity
    end
  end
end
