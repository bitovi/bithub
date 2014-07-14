class AddDeviseToUsers < ActiveRecord::Migration
  def self.up
    change_table(:users) do |t|
      ## Rememberable
      t.datetime :remember_created_at

      ## Trackable
      t.integer  :sign_in_count, :default => 0
      t.datetime :current_sign_in_at
      t.datetime :last_sign_in_at
      t.string   :current_sign_in_ip
      t.string   :last_sign_in_ip
    end
  end

  def self.down
    change_table(:users) do |t|
      t.remove :remember_created_at
      t.remove :sign_in_count
      t.remove :last_sign_in_ip
      t.remove :last_sign_in_at
      t.remove :current_sign_in_ip
      t.remove :current_sign_in_at
    end
  end
end
