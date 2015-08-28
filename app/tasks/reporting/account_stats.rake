namespace :reporting do
  desc "Creates a report with account stats"
  task :account_stats => :environment do

    tenant_names = Brand.pluck(:tenant_name)

    results = tenant_names.map do |tn|
      sql_command = <<-SQL
        select accounts.id,
          accounts.email,
          case when accounts.confirmed_at is null then 'no' else 'yes' end as is_confirmed,
          accounts.last_sign_in_at,
          count(distinct(embeds.id)) as embeds_count,
          count(distinct(services.id)) as services_count
        from accounts
        join account_organizations on accounts.id = account_organizations.account_id
        join organizations on organizations.id = account_organizations.organization_id
        join brands on brands.organization_id = organizations.id
        left join #{tn}.embeds on #{tn}.embeds.brand_id = brands.id
        left join #{tn}.services on #{tn}.services.embed_id = embeds.id
        where tenant_name = '#{tn}'
        group by accounts.id, accounts.email, accounts.confirmed_at, accounts.last_sign_in_at;
      SQL

      ActiveRecord::Base.connection.execute(sql_command).values
    end.reject {|v| v == []}


    CSV.open("/tmp/account_stats.csv", "wb", {:col_sep => ";"}) do |csv|
      csv << ['ID', 'Email', 'Email confirmed?', 'Last login at', 'Number of embeds', 'Number of services']
      results.each do |values|
        csv << values[0]
      end
    end

  end
end
