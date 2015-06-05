class CreateMonthlyBillingRecords < ActiveRecord::Migration
  def change
    create_table :monthly_billing_records do |t|

      t.references :monthly_billing

      t.string  :description
      t.integer :amount,      default: 0
      t.integer :price,       default: 0
      t.string  :currency,    default: 'USD'

      t.hstore  :props,       default: ''

      t.timestamps

    end if Apartment::Tenant.current == 'public'
  end
end
