module Accounts
  class AccountManager
    UserData = Struct.new(:uid, :name, :email, :nickname)

    def initialize(provider, oauth_data, current_user = nil)
      @provider = provider
      @oauth_data = oauth_data
      @current_user = current_user
    end

    def find_or_create_user
      @identity = Identity.find_or_create_with_oauth_data(@oauth_data)
      user = nil

      begin
        if current_user_exists?
          user = AccountLinker.new(@current_user, @identity, user_data).link
        elsif @identity.has_assigned_user?
          user = @identity.user
        else
          user = AccountCreator.new(@identity, user_data).create
        end
      rescue ActiveRecord::RecordInvalid => e
        Rails.logger.error e.message
      end
      user
    end

    def current_user_exists?
      @current_user != nil
    end

    private 
    def user_data
      if %w(meetup twitter github).include? @provider
        UserData.new(oauth_uid, oauth_name, oauth_email, oauth_nickname)
      else
        raise "Provider #{provider} not handled"
      end
    end

    def oauth_uid
      oauth_data['uid']
    end

    def oauth_nickname
      oauth_data['info']['nickname']
    end

    def oauth_name
      oauth_data['info']['name']
    end

    def oauth_email
      oauth_data['info']['email']
    end
  end
end
