class CreateEmbeds < ActiveRecord::Migration
  def change
    create_table :embeds do |t|
      t.string :name
      t.string :colorscheme
      t.string :layout
    end
  end
end
