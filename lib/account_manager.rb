class AccountManager
  attr_reader :user_api, :current_user

  def initialize(current_user = nil)
    @user_api = ThirdPartyUserInformer.new
    @current_user = current_user
  end

  def find_or_create_user(provider, oauth_data)
    name, email = self.class.pluck_data_for(provider, oauth_data)
    identity = Identity.find_or_create_with_oauth_data(oauth_data)

    if has_current_user?
      update_and_merge(identity, name, email)
    elsif identity.has_assigned_user?
      identity.user
    else
      create_and_collect(identity, name, email)
    end

  end

  def update_and_merge(identity, name, email)
    current_user.update_blank_oauth_attrs!({name: name, email: email})
    current_user.merge_identities!(identity)
    current_user
  end

  def create_and_collect(identity, name, email)
    user = identity.build_user({name: name, email: email})
    begin
      ActiveRecord::Base.transaction do
        identity.user.award_points_for_joining(identity.provider).save!
        #generate_follow_events_if_necessary(identity)
      end
      identity.user.collect_authored_events
    rescue ActiveRecord::InvalidRecord => e
      puts e.message
      puts e.backtrace.inspect
    end

    return user
  end

  def has_current_user?
    current_user != nil
  end

  def self.pluck_data_for(provider, oauth_data)
    case provider
    when "github"
      name = name_from(oauth_data)
      email = email_from(oauth_data)
    when "twitter" || "meetup"
      name = name_from(oauth_data)
    else
      raise "Provider #{provider} not handled"
    end
    [name, email]
  end

  def self.name_from(oauth_data)
    oauth_data['info']['name']
  end

  def self.email_from(oauth_data)
    oauth_data['info']['email']
  end
end
