module Messages

  def self.push_entity_to_embed(entity, embed)
    view = ActionView::Base.new('app/views', {}, ActionController::Base.new)
    decorated_entity = EntityDecorator.decorate(entity, context: { embed: embed })

    {
      meta: meta_msg(embed).merge({ is_public: entity.is_approved(embed) }),
      payload: view.render('api/v4/embed_entities/entity', { entity: decorated_entity })
    }
  end

  def self.pop_entity_from_embed(entity, embed)
    {
      meta: meta_msg(embed).merge({ is_public: true }),
      payload: { id: entity.id, is_approved: false }.to_json
    }
  end


  def self.clear_service_errors(service)
    {
      meta: meta_msg(service.embed),
      payload: {
        service: {
          id: service.id,
          has_errors: false
        }
      }
    }
  end

  def self.mark_service_as_errored(service)
    { 
      meta: meta_msg(service.embed),
      payload: {
        service: {
          id: service.id,
          has_errors: true
        }
      }
    }
  end

  def self.service_fetch_empty(service)
    { 
      meta: meta_msg(service),
      payload: { 
        service: { 
          id: service.id,
          empty_results: true 
        }
      }
    }
  end

  def self.meta_msg(embed)
    {
      brand_name: Apartment::Tenant.current,
      embed_id: embed.id,
    }
  end
end
