class CreateInviteCode < ActiveRecord::Migration
  def change
    create_table :invite_codes do |t|
      t.string :code
      t.integer :remaining_uses
      t.datetime :valid_until
    end
  end
end
