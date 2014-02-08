module Accounts
  class AccountManager
    attr_reader :user_api, :current_user, :identity

    RELEVANT_REPO_NAMES = Tag.tagged_with('req_favourites').map {|t| "bitovi/#{t.name}"}
    #RELEVANT_REPO_NAMES += %w(steal testee.js)
    #RELEVANT_REPO_NAMES << 'bithub-test/testy' if (Rails.env == 'test' || Rails.env == 'testing')

    RELEVANT_TWITTER_ACCOUNTS = {
      123763453 => 'bitovi',
      523041627 => 'canjs',
      589215872 => 'jquerypp',
      171351462 => 'funcunit',
      56956664 => 'javascriptmvc',
      12345678 => 'bitovi_bithub'
    }

    def initialize(current_user = nil)
      @user_api = ThirdPartyUserInformer.new
      @current_user = current_user
    end

    def find_or_create_user(provider, oauth_data)
      name, email = self.class.pluck_data_for(provider, oauth_data)
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

      begin
        create_missing_repos_and_watches!
      rescue Twitter::Error => e
        Rails.logger.error e.message
      rescue Github::Error => e
        Rails.logger.error e.message
      end

      identity.reload.user.collect_authored_entities.reward_if_eligible
      user
    end

    def update_and_merge(name, email)
      ActiveRecord::Base.transaction do
        current_user.update_blank_oauth_attrs!({name: name, email: email})
        current_user.award_points_for_linking(identity.provider)
        current_user.link_ident!(identity)
        current_user.reload.collect_authored_entities.reward_if_eligible
      end

      begin
        create_missing_repos_and_watches!
      rescue Twitter::Error => e
        Rails.logger.error e.message
      rescue Github::Error => e
        Rails.logger.error e.message
      end

      current_user
    end

    def create_missing_repos_and_watches!
      if identity.provider == 'twitter'
        create_internal_follows!(missing_friends)
      elsif identity.provider == 'github'
        create_internal_watches!(missing_repos)
      end
    end

    def missing_repos
      username = identity.source_data['nickname'] || identity.source_data[:nickname]
      rs = user_api.watched_repos(username)

      remote_repo_watches = rs.map{|r| (r[:full_name] || r['full_name'])} & RELEVANT_REPO_NAMES
      present_repo_watches = Entity.tagged_with(%w(github watch))
      .entity_by_origin_uid(identity.uid.to_s)
      .map {|e| e.source_data.andand['repo'].andand['full_name'] || e.props.andand['repo_name']}
      .uniq

      if (missing_repos = (remote_repo_watches - present_repo_watches)).length > 0
        rs.select{|r| missing_repos.include?(r[:full_name] || r['full_name'])}
      else
        []
      end
    end

    def missing_friends
      fs = user_api.followed_acct_ids(identity.uid)

      remote_friend_ids = fs.select{|f| RELEVANT_TWITTER_ACCOUNTS.keys.include?(f)}
      present_friend_ids = Entity.tagged_with(%w(twitter follow))
      .entity_by_origin_uid(identity.uid.to_s)
      .map{|e| e.source_data.andand['target'].andand['id']}
      .uniq

      if (missing_friends_ids = (remote_friend_ids - present_friend_ids)).length > 0
        missing_friends_ids.map {|id| {:id_str => id.to_s, :screen_name => RELEVANT_TWITTER_ACCOUNTS[id]}}
      else
        []
      end
    end

    def create_internal_follows!(accts)
      accts.map do |a|
        Dispatcher.new(
          Payload.new do
            Events::Twitter::CustomFollow.new(a, identity)
          end
        ).dispatch
      end
    end

    def create_internal_watches!(repos)
      repos.map do |r|
        Dispatcher.new(
          Payload.new do
            Events::Github::CustomWatch.new(r, identity)
          end
        ).dispatch
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

    def self.name_from(oauth_data)
      oauth_data['info']['name']
    end

    def self.email_from(oauth_data)
      oauth_data['info']['email']
    end
  end
end
