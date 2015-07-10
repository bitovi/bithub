class AddStateToServices < ActiveRecord::Migration
  def up
    add_column :services, :state, :string, default: 'loading'
  end

  def down
    remove_column :services, :state
  end
end
