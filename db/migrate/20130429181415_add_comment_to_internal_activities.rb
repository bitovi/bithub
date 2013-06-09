class AddCommentToInternalActivities < ActiveRecord::Migration
  def change
    add_column :internals, :comment, :string
  end
end
