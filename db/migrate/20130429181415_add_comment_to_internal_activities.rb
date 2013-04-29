class AddCommentToInternalActivities < ActiveRecord::Migration
  def up
    add_column :internals, :comment, :string
  end
  
  def down
    remove_column :internals, :comment
  end
end
