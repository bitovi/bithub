def new_profile_imgs
  twitter_api = Users::ThirdPartyUserInformer.new.twitter

  ids = Bit.where(:feed_name => 'twitter').where(:type_name => 'tweet').map{|t| t.props["origin_author_id"]}.uniq.map{|id| id.to_i}
  Hash[twitter_api.users(ids).map {|u| [u.id, u.profile_image_url]}]
end

def refresh_tweet_origin_avatar_urls(resp_hash)
  resp_hash.each do |id, img_url|
    Bit.origin_author(id).all.each do |bit|
      bit.props['origin_author_avatar_url'] = img_url.to_s
      bit.save
    end
  end
end

namespace :data do
  desc "Updates tweets that don't have a user assigned with new profile images"
  task :update_tweets_with_new_profile_imgs => :environment do
    puts "--- BEGIN update_tweets_with_new_profile_imgs"
    refresh_tweet_origin_avatar_urls(new_profile_imgs)
    puts "--- END update_tweets_with_new_profile_imgs"
  end
end
