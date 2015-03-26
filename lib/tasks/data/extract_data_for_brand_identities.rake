namespace :data do
  desc "Updates existing BrandIdenities with extracted_data"
  task :extract_data_for_brand_identities => :environment do

    puts "---"
    puts "\nRe-extracting BrandIdentities"

    facebook_total = 0; facebook_done = 0;
    BrandIdentity.where(provider: 'facebook').each do |ident|
      ident.extracted_data = {} unless ident.extracted_data
      ident.extracted_data[:credentials] = ident.source_data[:credentials]
      ident.extracted_data[:long_lived_access_token] = ident.source_data[:long_lived_access_token]
      ident.extracted_data[:pages] = ident.source_data[:pages]
      facebook_total += 1
      facebook_done += 1 if ident.save
    end
    puts "facebook total: #{facebook_total}, done: #{facebook_done}"


    github_total = 0; github_done = 0;
    BrandIdentity.where(provider: 'github').each do |ident|
      ident.extracted_data = {} unless ident.extracted_data
      ident.extracted_data[:credentials] = ident.source_data[:credentials]
      ident.extracted_data[:repos] = ident.source_data[:repos]
      ident.extracted_data[:orgs] = ident.source_data[:orgs]
      github_total += 1
      github_done += 1 if ident.save
    end
    puts "github total: #{github_total}, done: #{github_done}"

    twitter_total = 0; twitter_done = 0;
    BrandIdentity.where(provider: 'twitter').each do |ident|
      ident.extracted_data = {} unless ident.extracted_data
      ident.extracted_data[:credentials] = ident.source_data[:credentials]
      twitter_total += 1
      twitter_done += 1 if ident.save
    end
    puts "twitter total: #{twitter_total}, done: #{twitter_done}"

    disqus_total = 0; disqus_done = 0;
    BrandIdentity.where(provider: 'disqus').each do |ident|
      ident.extracted_data = {} unless ident.extracted_data
      ident.extracted_data[:credentials] = ident.source_data[:credentials]
      ident.extracted_data[:forums] = ident.source_data[:forums]
      disqus_total += 1
      disqus_done += 1 if ident.save
    end
    puts "disqus total: #{disqus_total}, done: #{disqus_done}"

    meetup_total = 0; meetup_done = 0;
    BrandIdentity.where(provider: 'meetup').each do |ident|
      ident.extracted_data = {} unless ident.extracted_data
      ident.extracted_data[:credentials] = ident.source_data[:credentials]
      ident.extracted_data[:groups] = ident.source_data[:groups]
      meetup_total += 1
      meetup_done += 1 if ident.save
    end
    puts "meetup total: #{meetup_total}, done: #{meetup_done}"

    instagram_total = 0; instagram_done = 0;
    BrandIdentity.where(provider: 'instagram').each do |ident|
      ident.extracted_data = {} unless ident.extracted_data
      ident.extracted_data[:credentials] = ident.source_data[:credentials]
      instagram_total += 1
      instagram_done += 1 if ident.save
    end
    puts "instagram total: #{instagram_total}, done: #{instagram_done}"
  end
end
