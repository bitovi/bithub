module Messages

  def self.push_bit_to_hub(bit, hub)
    view = ActionView::Base.new('app/views', {}, ActionController::Base.new)
    decorated_bit = BitDecorator.decorate(bit, context: { hub: hub })

    {
      meta: meta_msg(hub).merge({ is_public: bit.is_approved(hub) }),
      payload: view.render('api/v4/moderations/bit', { bit: decorated_bit })
    }
  end

  def self.pop_bit_from_hub(bit, hub)
    {
      meta: meta_msg(hub).merge({ is_public: true }),
      payload: { id: bit.id, is_approved: false }.to_json
    }
  end


  def self.clear_service_errors(service)
    {
      meta: meta_msg(service.hub),
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
      meta: meta_msg(service.hub),
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

  def self.meta_msg(hub)
    {
      brand_name: Apartment::Tenant.current,
      hub_id: hub.id,
    }
  end
end
