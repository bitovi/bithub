class EventsController < ApplicationController

  def index
    events = Event.includes(:rule).limit(10)
    events.each do |e|
      Rails.logger.info e.rule.to_yaml
    end

    render :json => events
  end
end
