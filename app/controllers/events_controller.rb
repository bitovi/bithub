class EventsController < ApplicationController
  respond_to :json

  def index
    muster_query = request.env['muster.query']
    Rails.logger.info muster_query

    scope = Event.scoped
    scope = scope.where(muster_query[:where]) if !muster_query[:where].blank?
    scope = scope.joins(muster_query[:joins]) if !muster_query[:joins].blank?
    scope = scope.includes(muster_query[:includes]) if !muster_query[:includes].blank?
    scope = scope.order(muster_query[:order]) if !muster_query[:order].blank?
    scope = scope.limit(muster_query[:limit])
    # @events = @events.nest_by(muster_query[:group]) if !muster_query[:group].blank?
    
    # @events = scope.nest_by(:category)
    @events = scope.all    

    respond_with(@events)
    # render :json => @events
  end

  def show
    @event = Event.find(params[:id])
    render :show
  end

end
