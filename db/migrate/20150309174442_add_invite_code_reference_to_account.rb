class AddInviteCodeReferenceToAccount < ActiveRecord::Migration
  def change
    unless column_exists? 'public.accounts', 'invite_code_id'
      add_column :accounts, :invite_code_id, :integer
    end
  end
end
