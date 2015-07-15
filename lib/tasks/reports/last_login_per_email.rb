namespace :reports do
  desc "Creates a report with account stats"
  task :account_stats => :environment do

    results = Brand.pluck(:tenant_name).map do |tn|
      sql_command = <<-SQL
        select email,
          case when confirmed_at is null then 'no' else 'yes' end as is_confirmed,
          last_sign_in_at,
          count(distinct(embeds.id)) as embeds_count,
          count(distinct(services.id)) as services_count
        from accounts
        join accounts_organizations on accounts.id = accounts_organizations.account_id
        join organizations on organizations.id = accounts_organizations.organization_id
        join brands on brands.organization_id = organizations.id
        left join #{tn}.embeds on #{tn}.embeds.brand_id = brands.id
        left join #{tn}.services on #{tn}.services.embed_id = embeds.id
        where tenant_name = '#{tn}'
        group by email, confirmed_at, last_sign_in_at;
      SQL

      [sql_command, ActiveRecord::Base.connection.execute(sql_command).values]
    end

    CSV.open("/tmp/account_stats.csv", "wb", {:col_sep => ";"}) do |csv|
      csv << ['Email', 'Email confirmed?', 'Last login at', 'Number of embeds', 'Number of services']
      results.each do |values|
        csv << values[1][0]
      end
    end

  end
end
