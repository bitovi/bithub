namespace :data do
  desc "Update junk identities from 3rd party APIs"
  task :update_identities => :environment do

    @twitter_client = Twitter::REST::Client.new do |config|
      config.consumer_key = ENV['TWITTER_CONSUMER_KEY']
      config.consumer_secret = ENV['TWITTER_CONSUMER_SECRET']
      config.oauth_token = ENV['TWITTER_OAUTH_TOKEN']
      config.oauth_token_secret = ENV['TWITTER_OAUTH_TOKEN_SECRET']
    end

    module Fetchers
      def self.github(uid)
        res = open("https://api.github.com/user/#{uid}")
        YAML::load(res.read)
      end

      def self.twitter(client, uid)
        client.user(uid)
      end
    end

    module Processors
      def self.github(sd)
        {
          'nickname' => sd.andand['login'],
          'email'    => sd.andand['email'],
          'name'     => sd.andand['name'],
          'image'    => sd.andand['avatar_url'],
          'urls'     => {
            'Github' => sd.andand['html_url'],
            'Blog'   => sd.andand['blog']
          }
        }
      end

      def self.twitter(user)
        {
          'nickname'    => user.screen_name,
          'name'        => user.name,
          'location'    => user.location,
          'image'       => user.profile_image_url.to_s,
          'description' => user.description,
          'urls'        => {
            'Website'   => user.website.to_s,
            'Twitter'   => user.url.to_s
          }
        }
      end
    end

    puts "---"

    ### Deleting

    puts "\nDeleting identities without origin uid"
    result = Identity.where(uid: nil).destroy_all
    puts "\t#{result.count} uids deleted!"

    ### Updating github

    uids = Identity
      .where(provider: 'github')
      .select {|i| !i.source_data.andand['nickname']}
      .pluck(:uid)
      .flatten
    puts "\nUpdating #{uids.count} Github identities without nickname in source_data"

    uids.each do |uid|
      begin
        sd = Fetchers::github(uid)
        processed = Processors::github(sd)

        ident = Identity.where(uid: uid).first
        ident.source_data = processed
        ident.save!

        puts "\tUpdated for uid #{uid}, nickname #{ident.source_data['nickname']}"
      rescue Exception => e
        puts "\tFailed for uid #{uid}; #{e.message}"
      end
    end

    ### Updating twitter

    # rate limit 180 per window, window == 15min

    uids = Identity
      .where(provider: 'twitter')
      .select {|i| !i.source_data.andand['nickname']}
      .pluck(:uid)
      .flatten
    puts "\nUpdating #{uids.count} Twitter identities without nickname in source_data"

    uids.each do |uid|
      begin
        user = Fetchers::twitter(@twitter_client, uid)
        processed = Processors::twitter(user)

        ident = Identity.where(uid: uid).first
        ident.source_data = processed
        ident.save!

        puts "\tUpdated for uid #{uid}, nickname #{ident.source_data['nickname']}"
      rescue Exception => e
        puts "\tFailed for uid #{uid}; #{e.message}"
      end
    end

  end
end
