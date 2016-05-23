namespace :reporting do
  desc "Creates a report with user stats"
  task :user_stats => :environment do

    tenant_names = Brand.pluck(:tenant_name)

    results = tenant_names.map do |tn|
      sql_command = <<-SQL
        select users.id,
          users.email,
          case when users.confirmed_at is null then 'no' else 'yes' end as is_confirmed,
          users.last_sign_in_at,
          count(distinct(hubs.id)) as hubs_count,
          count(distinct(services.id)) as services_count
        from users
        join user_organizations on users.id = user_organizations.user_id
        join organizations on organizations.id = user_organizations.organization_id
        join brands on brands.organization_id = organizations.id
        left join #{tn}.hubs on #{tn}.hubs.brand_id = brands.id
        left join #{tn}.services on #{tn}.services.hub_id = hubs.id
        where tenant_name = '#{tn}'
        group by users.id, users.email, users.confirmed_at, users.last_sign_in_at;
      SQL

      ActiveRecord::Base.connection.execute(sql_command).values
    end.reject {|v| v == []}


    CSV.open("/tmp/user_stats.csv", "wb", {:col_sep => ";"}) do |csv|
      csv << ['ID', 'Email', 'Email confirmed?', 'Last login at', 'Number of hubs', 'Number of services']
      results.each do |values|
        csv << values[0]
      end
    end

  end
end
