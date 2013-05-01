class AddAttachmentImageToEvents < ActiveRecord::Migration
  def self.up
    change_table :events do |t|
      add_column :events, :image, :string
    end
  end

  def self.down
    remove_column :events, :image
  end
end
