namespace :data do
  desc "Updates existing BrandIdenities with extracted_data"
  task :extract_data_for_brand_identities => :environment do

    puts "---"
    puts "\nRe-extracting BrandIdentities"

    facebook_total = 0; facebook_done = 0;
    BrandIdentity.where(provider: 'facebook').each do |ident|
      ident.extracted_data = {} unless ident.extracted_data
      ident.extracted_data['long_lived_access_token'] = ident.source_data['long_lived_access_token']
      ident.extracted_data['pages'] = ident.source_data['pages']
      ident.extracted_data_will_change!
      facebook_total += 1
      facebook_done += 1 if ident.save
    end
    puts "facebook total: #{facebook_total}, done: #{facebook_done}"

    github_total = 0; github_done = 0;
    BrandIdentity.where(provider: 'github').each do |ident|
      ident.extracted_data = {} unless ident.extracted_data
      ident.extracted_data['repos'] = ident.source_data['repos']
      ident.extracted_data['orgs'] = ident.source_data['orgs']
      ident.extracted_data_will_change!
      github_total += 1
      github_done += 1 if ident.save
    end
    puts "github total: #{github_total}, done: #{github_done}"

    disqus_total = 0; disqus_done = 0;
    BrandIdentity.where(provider: 'disqus').each do |ident|
      ident.extracted_data = {} unless ident.extracted_data
      ident.extracted_data['forums'] = ident.source_data['forums']
      ident.extracted_data_will_change!
      disqus_total += 1
      disqus_done += 1 if ident.save
    end
    puts "disqus total: #{disqus_total}, done: #{disqus_done}"

    meetup_total = 0; meetup_done = 0;
    BrandIdentity.where(provider: 'meetup').each do |ident|
      ident.extracted_data = {} unless ident.extracted_data
      ident.extracted_data['groups'] = ident.source_data['groups']
      ident.extracted_data_will_change!
      meetup_total += 1
      meetup_done += 1 if ident.save
    end
    puts "meetup total: #{meetup_total}, done: #{meetup_done}"

    puts "--- replacing source_data with source_data[:oauth]"
    BrandIdentity.all.each do |ident|
      ident.source_data = ident.source_data['oauth']
      ident.source_data_will_change!
      ident.save
    end
  end
end
