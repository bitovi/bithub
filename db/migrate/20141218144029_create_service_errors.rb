class CreateServiceErrors < ActiveRecord::Migration
  def change
    create_table :service_errors do |t|
      t.string :klass
      t.string :message
      t.references :service
    end
  end
end
