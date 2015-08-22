class CreateDripSubscriberJob < ActiveJob::Base
  def perform(email)
    DripManager.new.create_or_update_subscriber(email)
  end
end
