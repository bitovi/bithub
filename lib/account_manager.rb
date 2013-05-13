module AccountManager
  def self.find_or_create_user(provider, oauth_data, current_user = nil)
    name, email = pluck_data_for(provider, oauth_data)

    identity = find_or_create_identity(oauth_data)

    case
    when current_user
      user = current_user
      user.update_blank_oauth_attrs!({name: name, email: email})
      user.merge_identities!(identity)
    when identity.has_assigned_user?
      user = identity.user
    else
      user = identity.create_user({name: name, email: email})
      identity.save!
      user.collect_authored_events
    end

    return user
  end

  def self.find_or_create_identity(oauth_data)
    Identity.find_or_create_with_oauth_data(oauth_data)
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
