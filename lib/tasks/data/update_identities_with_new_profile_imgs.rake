namespace :data do
  desc "Update junk identities from 3rd party APIs"
  task :update_identities_with_new_profile_imgs => :environment do

    twitter_api = Accounts::ThirdPartyUserInformer.new.twitter

    puts "---"
    puts "\nUpdating Twitter identities with new profile imgs"

    twitter_uids = Identity.where(provider: 'twitter').pluck(:uid).flatten
    new_data = Hash[twitter_api.users(twitter_uids).map {|u| [u.id, u.profile_image_url]}]

    new_data.each do |id, img_url|
      if (ident = Identity.where(:uid => id, :provider => 'twitter').first)
        ident.source_data = {} if ident.source_data.nil?
        ident.source_data['image'] = img_url.to_s
        ident.save
      end
    end
    
  end
end
