class AddInviteCodeReferenceToAccount < ActiveRecord::Migration
  def change
    unless column_exists? :accounts, :invite_code
      add_column :accounts, :invite_code_id, :integer
    end
  end
end
