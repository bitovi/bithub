class AddConstraintsOnAccounts < ActiveRecord::Migration
  def up
    execute "ALTER TABLE accounts ADD CONSTRAINT fk_accounts_brands FOREIGN KEY (brand_id) REFERENCES brands(id);"
  end

  def down
    execute "ALTER TABLE accounts DROP CONSTRAINT fk_accounts_brands;"
  end
end
