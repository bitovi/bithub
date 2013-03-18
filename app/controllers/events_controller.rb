class EventsController < ApplicationController
  respond_to :json

  def index
    muster_query = request.env['muster.query']
    Rails.logger.info muster_query

    @events = Event.scoped
    @events = @events.where(muster_query[:where]) if !muster_query[:where].blank?
    @events = @events.joins(muster_query[:joins]) if !muster_query[:joins].blank?
    @events = @events.includes(muster_query[:includes]) if !muster_query[:includes].blank?
    @events = @events.order(muster_query[:order]) if !muster_query[:order].blank?
    @events = @events.limit(muster_query[:limit])

    # render :index, locals: { muster_query: muster_query }
    render :json => Rabl.render(@events, 'events/index', :view_path => 'app/views', :locals => { qs: muster_query })
  end

end
