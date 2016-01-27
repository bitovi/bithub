require 'guzzler/redis_api'

class Notifier

  def self.notify_client(about, args)
    new.notify_client(about, args)
  end

  def notify_client(about, args)
    if about == :entity_persisted || about == :entity_moderated
      entity_touched(args.fetch(:entity))
    elsif about == :entity_routed_to_service
      entity_routed_to_service(args.fetch(:service))
    elsif about == :service_error_raised
      service_error_raised(args.fetch(:service_error))
    end
  end

  private

  # Notify client that an entity was updated in some way.
  def entity_touched(entity)
    return if (entity.is_pending? || entity.is_child?)

    entity.embeds.reload.each do |embed|
      Guzzler.lpush('liveservice:entities', Messages.push_entity_to_embed(entity, embed))
      if !entity.is_approved(embed)
        # We don't want to send the whole entity publicly when it is blocked but we need to send just enough so it can be removed from an active embed. This way live embeds (like on event media walls) can be moderated and updated in real-time.
        Guzzler.lpush('liveservice:entities', Messages.pop_entity_from_embed(entity, embed))
      end
    end
  end

  # Notify client that an event was routed to a service so that it can mark it as a loaded service and/or clear the error marker.
  def entity_routed_to_service(service)
    Guzzler.lpush('liveservice:services', Messages.clear_service_errors(service))
  end

  # Notify client that a error was raised while consuming service so that it can mark it as an errored service.
  def service_error_raised(service_error)
    Guzzler.lpush('liveservice:services', Messages.mark_service_as_errored(service_error))
  end

  def empty_response_fetched(service)
  end
end
