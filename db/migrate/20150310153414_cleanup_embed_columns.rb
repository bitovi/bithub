class CleanupEmbedColumns < ActiveRecord::Migration
  def change
    remove_column :embeds, :layout
    remove_column :embeds, :colorscheme
  end
end
