namespace :data do
  desc "Update junk identities from 3rd party APIs"
  task :update_identities => :environment do

    @tpui = Accounts::ThirdPartyUserInformer.new


    puts "---"

    ### Delete junk

    puts "\nDeleting identities without origin uid"
    result = Identity.where(uid: nil).destroy_all
    puts "\t#{result.count} uids deleted!"

    ### Update twitter

    uids = Identity
      .where(provider: 'twitter')
      .select {|i| !i.source_data.andand['nickname']}
      .pluck(:uid)
      .flatten

    puts "\nUpdating #{uids.count} Twitter identities without nickname in source_data"

    uids.each do |uid|
      begin
        ident = Identity.where(uid: uid).first
        ident.update_source_data(@tpui.from_twitter_by_uid(uid))
        ident.save!

        puts "\tUpdated for uid #{uid}, nickname #{ident.source_data['nickname']}"
      rescue Exception => e
        puts "\tFailed for uid #{uid}; #{e.message}"
      end
    end

    ### Update github
    uids = Identity
      .where(provider: 'github')
      .select {|i| !i.source_data.andand['nickname']}
      .pluck(:uid)
      .flatten

    puts "\nUpdating #{uids.count} Github identities without nickname in source_data"

    uids.each do |uid|
      begin
        ident = Identity.where(uid: uid).first
        ident.update_source_data(@tpui.from_github_by_uid(uid))
        ident.save!

        puts "\tUpdated for uid #{uid}, nickname #{ident.source_data['nickname']}"
      rescue Exception => e
        puts "\tFailed for uid #{uid}; #{e.message}"
      end
    end

  end
end
