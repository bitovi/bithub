namespace :migrators do
  desc "Migrates users and their points"
  task :users => :environment do
    require 'mongoid'
    require "#{Rails.root}/lib/mongoid_models/user_mongo.rb"

    class UserMongo
      include Mongoid::Document
      store_in collection: 'users'
      field :name
      field :email
      #field :email_hash
      field :joined_ts, type: DateTime
      #field :points
      field :providers # :twitter._json, :github._json
      field :address
      field :city
      field :postalCode
      field :stateProvince
      field :country
      field :upvotes, type: Array
    end

    # Mongo connection
    Mongoid.load!("config/mongoid.yml")

    UserMongo.all().each do |mongo_user|
      new_user_hash = {
        :name => mongo_user[:name],
        :email => (mongo_user[:email] && mongo_user[:email].include?('@')) ? mongo_user[:email] : nil, # dummy check
        :address => mongo_user[:address],
        :city => mongo_user[:city],
        :postal => mongo_user[:postalCode],
        :state => mongo_user[:stateProvince],
        #:country => mongo_user[:country],
      }

      Rails.logger.info "Creating a user" 
      new_user = User.new(new_user_hash)

      if mongo_user.providers
        mongo_user.providers.each do |key, provider|
          new_user.identities << Identity.new({:provider => key, :source_data => provider['_json'], :uid => provider['id'].to_s })
        end
      end

      begin
        new_user.save!
        Rails.logger.info "USER SAVED | #{new_user[:name]}, #{new_user[:email]}"
      rescue ActiveRecord::RecordInvalid => invalid
        Rails.logger.info "USER INVALID | #{new_user[:name]}, #{new_user[:email]}"
        Rails.logger.info invalid.record.errors.messages.to_yaml
        next
      end

      new_user.collect_authored_events

      if mongo_user.upvotes
        mongo_user.upvotes.each do |event_id|
          id = event_id.to_s
          if Event.where("props -> 'mongo_id' = '#{id}'").length > 0
            event = Event.where("props -> 'mongo_id' = '#{id}'").first
            upvote = Upvote.new({:actor => new_user, :applies_to => event, :value => 1})
            begin
              upvote.save!
              Rails.logger.info "UPVOTE SAVED | #{new_user.name}, #{event.title}"
            rescue ActiveRecord::RecordInvalid => invalid
              Rails.logger.info "UPVOTE INVALID | #{new_user.name}, #{event.title}"
              Rails.logger.info invalid.record.errors.messages.to_yaml
            end
          end
        end
      end
    end
  end
end
