module Accounts
  class AccountManager
    attr_reader :current_user, :identity

    def initialize(current_user = nil)
      @current_user = current_user
    end

    def find_or_create_user(provider, oauth_data)
      name, email = self.class.pluck_data_for(provider, oauth_data)
      @oauth_data = oauth_data
      @identity = Identity.find_or_create_with_oauth_data(oauth_data)
      user = nil

      begin
        if current_user_exists?
          user = update_and_merge(name, email)
        elsif identity.has_assigned_user?
          user = identity.user
        else
          user = create_and_collect(name, email)
        end
      rescue ActiveRecord::RecordInvalid => e
        Rails.logger.error e.message
      end
      user
    end

    def create_and_collect(name, email)
      user = identity.build_user({name: name, email: email})
      ActiveRecord::Base.transaction do
        identity.user.award_points_for_linking(identity.provider)
        identity.save!
      end

      create_missing_repos_and_stars!
      # identity.reload.user.collect_authored_entities.reward_if_eligible
      user
    end

    def update_and_merge(name, email)
      ActiveRecord::Base.transaction do
        current_user.update_blank_oauth_attrs!({name: name, email: email})
        current_user.award_points_for_linking(@identity.provider)
        current_user.link_ident!(@identity)
        current_user.reload.collect_authored_entities.reward_if_eligible
      end

      create_missing_repos_and_stars!
      current_user
    end

    def create_missing_repos_and_stars!
      if @identity.provider == 'twitter'
        create_internal_follows!
      elsif @identity.provider == 'github'
        create_internal_stars!
      end
    end

    def create_internal_follows!
      ApiCache.where(provider: @identity.provider, uid: @identity.uid.to_s).each do |res|
        data = {
          source_data: {
            uid: uid_from(@oauth_data),
            nickname: nickname_from(@oauth_data),
            target_screen_name: res.name,
            custom_follow: true,
          },
        }
        Dispatcher.new.dispatch(data, @identity.provider)
      end
    end
    
    def create_internal_stars!
      ApiCache.where(provider: @identity.provider, uid: @identity.uid.to_s).each do |res|
        data = {
          source_data: {
            uid: uid_from(@oauth_data),
            nickname: nickname_from(@oauth_data),
            repo_name: res.name,
            custom_watch: true,
          }
        }
        Dispatcher.new.dispatch(data, @identity.provider)
      end
    end

    def current_user_exists?
      current_user != nil
    end

    def self.pluck_data_for(provider, oauth_data)
      case provider
      when "github"
        name = name_from(oauth_data)
        email = email_from(oauth_data)
      when "twitter"
        name = name_from(oauth_data)
      when "meetup"
        name = name_from(oauth_data)
      else
        raise "Provider #{provider} not handled"
      end
      [name, email]
    end

    def uid_from(oauth_data)
      oauth_data['uid']
    end

    def nickname_from(oauth_data)
      oauth_data['info']['nickname']
    end

    # Class methods
    def self.name_from(oauth_data)
      oauth_data['info']['name']
    end

    def self.email_from(oauth_data)
      oauth_data['info']['email']
    end
  end
end
