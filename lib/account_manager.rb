class AccountManager
  attr_reader :user_api, :current_user, :identity
    
  RELEVANT_REPO_NAMES = YAML.load_file('config/tag_aliases.yml').keys.map{|r| 'bitovi/' + r}
  RELEVANT_FRIENDS = YAML.load_file('config/tag_aliases.yml').keys << 'bitovi'

  def initialize(current_user = nil)
    @user_api = ThirdPartyUserInformer.new
    @current_user = current_user
  end

  def find_or_create_user(provider, oauth_data)
    name, email = self.class.pluck_data_for(provider, oauth_data)
    @identity = Identity.find_or_create_with_oauth_data(oauth_data)

    if has_current_user?
      update_and_merge(name, email)
    elsif identity.has_assigned_user?
      identity.user
    else
      create_and_collect(identity, name, email)
    end
  end

  def update_and_merge(name, email)
    current_user.update_blank_oauth_attrs!({name: name, email: email})
    current_user.merge_identities!(identity)
    current_user
  end

  def create_and_collect(name, email)
    user = identity.build_user({name: name, email: email})
    begin
      ActiveRecord::Base.transaction do
        identity.user.award_points_for_joining(identity.provider)
        identity.save!
        create_missing_repos_and_watches
      end
      identity.user.collect_authored_events
    rescue ActiveRecord::RecordInvalid => e
      puts e.message
      puts e.backtrace.inspect
    end
    user
  end

  def create_missing_repos_and_watches
    if identity.provider == 'twitter'
      create_internal_follows(missing_friends)
    elsif identity.provider == 'github'
      create_internal_watches(missing_repos)
    end
  end

  def missing_repos
    rs = user_api.watched_repos

    remote_repo_watches = rs.select{|r| RELEVANT_REPO_NAMES.include?(r[:full_name] || r['full_name'])}
                            .map{|r| (r[:full_name] || r['full_name'])}

    present_repo_watches = Event.tagged_with(%w(github watch_event))
                                .event_by_origin_uid(identity.uid.to_s)
                                .map{|e| e.props['repo']}
                                .uniq

    if (missing_repos = (remote_repo_watches - present_repo_watches)).length > 0
      p missing_repos
      rs.select{|r| missing_repos.include?(r[:full_name] || r['full_name'])}
    else
      []
    end
  end

  def missing_friends
    fs = user_api.followed_accts

    remote_friend_names = fs.select{|r| RELEVANT_FRIENDS.include?(r[:screen_name] || r['screen_name'])}
                            .map{|r| (r[:screen_name] || r['screen_name'])}

    present_friend_names = Event.tagged_with(%w(twitter follow_event))
                                .event_by_origin_uid(identity.uid.to_s)
                                .map{|e| e.props['target']}
                                .uniq

    if (missing_friends = (remote_friend_names - present_friend_names)).length > 0
      p missing_friends
      fs.select{|r| missing_friends.include?(r[:screen_name] || r['screen_name'])}
    else
      []
    end
  end


  def create_internal_follows(accts)
    accts.map do |a|
      for_hk = identity.uid.to_s + (a['id_str'] || a[:id_str])
      hash_key = Digest::MD5.hexdigest(for_hk)
      screen_name = a[:screen_name] || a['screen_name']

      e = Event.new({
        title: "followed #{screen_name}",
        hash_key: hash_key,
        origin_ts: Time.now,
        origin_date: Date.today,
        props: {
          origin_author_id: identity.uid,
          target: screen_name,
          feed: "twitter",
          category: "digest",
          tags: ["follow_event"]
        }
      })

      e.determine.save!
      e
    end
  end

  def create_internal_watches(repos)
    repos.map do |r|
      for_hk = identity.uid.to_s + (r[:id] || r["id"]).to_s
      hash_key = Digest::MD5.hexdigest(for_hk)
      repo_name = r[:full_name] || r['full_name']

      e = Event.new({
        title: "started watching #{repo_name}",
        hash_key: hash_key,
        origin_ts: Time.now,
        origin_date: Date.today,
        props: {
          origin_author_id: identity.uid,
          repo: repo_name,
          feed: "github",
          type: "watch_event",
          category: "digest",
          tags: [r[:name]]
        }
      })

      e.determine.save!
      e
    end
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
