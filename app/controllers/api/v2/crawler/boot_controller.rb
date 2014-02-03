class Api::V2::Crawler::BootController < Api::V1::BaseController

  def event_ids
    ids = Entity.feed('meetup').type('event').pluck(:origin_id)
    render json: ids
  end
  
end
