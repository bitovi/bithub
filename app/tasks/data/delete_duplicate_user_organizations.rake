namespace :data do
  desc "Deletes duplicated user organizations relations"
  task :delete_duplicate_user_organizations => :environment do
    puts "--- BEGIN delete_duplicate_user_organizations"

    # create hash where key is [org_id, acc_id] and value is list of record ids
    # then delete duplicates
    counts = UserOrganization.all.reduce(Hash.new { |h, k| h[k] = [] }) do |acc, ao|
      acc[ [ao.user_id, ao.organization_id] ].push ao.id
      acc
    end.each do |k, v|
      UserOrganization.destroy v.last if v.count > 1
    end

    puts "--- END delete_duplicate_user_organizations"
  end
end
