class ServiceError < ActiveRecord::Base
  include Traits::AmqpDeclaration

  belongs_to :service

  # Hooks
  after_commit :notify_liveservice

  private 

  def notify_liveservice
    Rails.logger.info "Publishing error to liveservice #{msg}"
    x('x.liveservice').publish(msg.to_json, routing_key: :services)
  end

  def msg
    curr_brand = Brand.current
    { 
      meta: {
        brand_id: curr_brand.id,
        brand_name: curr_brand.name,
        embed_id: service.embed.id
      },
      payload: {
        service: {
          id: service.id,
          has_errors: true
        }
      }
    }
  end
end
