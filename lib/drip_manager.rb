class DripManager

  def create_or_update_subscriber(email, opts={})
    force = opts.fetch(:force) { false }

    if force || Rails.env.production?
      client.create_or_update_subscriber email
    end
  end

  def client
    @client ||= Drip::Client.new do |c|
      c.api_key = ENV['DRIP_API_KEY']
      c.user_id = ENV['DRIP_ACCOUNT_ID']
    end
  end
end
