class CreateDripSubscriberJob < ApplicationJob
  def perform(email)
    DripManager.new.create_or_update_subscriber(email)
  end
end
