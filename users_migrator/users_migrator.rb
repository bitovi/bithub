#!/usr/bin/env ruby

app_root = File.expand_path(File.join(File.dirname(__FILE__), '..'))
require "#{app_root}/config/environment"
require "#{app_root}/users_migrator/user_mongo"

# Logging
$log = Log4r::Logger.new('users_migrator')
$log.add(Log4r::StdoutOutputter.new('console', {
  :formatter => Log4r::PatternFormatter.new(:pattern => "[#{Process.pid}:%l] %d :: %m")
}))

# Mongo connection
Mongoid.load!("config/mongoid.yml")

# iter all events
#UserMongo.all.each do |user|
#end

UserMongo.all().each do |mongo_user|
  new_user_hash = {
    :name => mongo_user[:name],
    :email => mongo_user[:email],
    :address => mongo_user[:address],
    :city => mongo_user[:city],
    :postal => mongo_user[:postalCode],
    :state => mongo_user[:stateProvince],
    #:country => mongo_user[:country],
  }

  @new_user = User.new(new_user_hash)
  
  if mongo_user.providers
    mongo_user.providers.each do |key, provider|
      @new_user.identities << Identity.new({:provider => key, :source_data => provider['_json'], :uid => provider['id'].to_s })
    end
  end

  begin
    @new_user.save!
  rescue ActiveRecord::RecordInvalid => invalid
    $log.info "Save failed | META: #{@new_user}"
    $log.info invalid.record.errors.messages.to_yaml
  end

end

