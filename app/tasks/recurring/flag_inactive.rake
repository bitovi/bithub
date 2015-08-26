namespace :recurring do

  desc 'Flags brands that haven\'t confirmed their accounts and haven\'t logged in a week as inactive'
  task :flag_inactive => :environment do
    Rails.logger.info "[WHENEVER] Flagging inactive accounts"

    ActiveRecord::Base.connection.execute <<-SQL
      BEGIN;
      UPDATE brands SET is_active = 't';

      UPDATE brands SET is_active = 'f'
      FROM (
          SELECT
            organizations. ID,
            COUNT (confirmed_at) AS confirmed_accounts,
            MAX (accounts.last_sign_in_at) AS last_sign_in_at
          FROM
            accounts,
            account_organizations,
            organizations
          WHERE
            accounts.id = account_organizations.account_id
          AND organizations.id = account_organizations.organization_id
          GROUP BY
            organizations.id
        ) AS org_data
      WHERE
        org_data.id = brands.organization_id
      AND org_data.last_sign_in_at < now() :: TIMESTAMP - '1 week' :: INTERVAL
      AND org_data.confirmed_accounts = 0;

      COMMIT;
    SQL

    Rails.logger.info "[WHENEVER] Flagged inactive accounts."
  end
end
