class AddInviteCodeReferenceToAccount < ActiveRecord::Migration
  def change
    change_table :accounts do |t|
      t.references :invite_code unless t.column_exists? :invite_code
    end
  end
end
