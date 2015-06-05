class CreateMonthlyBillings < ActiveRecord::Migration
  def change
    create_table :monthly_billings do |t|

      t.references :organization

      t.timestamp :period_beginning
      t.timestamp :period_end

      t.integer   :total
      t.string    :currency, default: 'USD'
      t.text      :description

      t.string    :stripe_customer_id
      t.string    :stripe_charge_id
      t.string    :stripe_status
      t.timestamp :charged_at

      t.hstore    :props, default: ''

      t.timestamps

    end if Apartment::Tenant.current == 'public'
  end
end
