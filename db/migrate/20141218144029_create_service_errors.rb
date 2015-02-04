class CreateServiceErrors < ActiveRecord::Migration
  def change
    create_table :service_errors do |t|
      t.string :klass
      t.string :message
      t.text :backtrace
      t.references :service
      t.timestamps
    end
  end
end
