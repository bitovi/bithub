class ServiceError < ActiveRecord::Base
  include Traits::AmqpDeclaration

  belongs_to :service
  validates_uniqueness_of :klass, scope: :service_id

  # Hooks
  after_commit :notify_liveservice

  private 

  def notify_liveservice
    Rails.logger.info "Publishing error to liveservice #{msg}"
    x('x.liveservice').publish(msg, :services)
  end

  def msg
    { 
      meta: {
        brand_name: Brand.current,
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
