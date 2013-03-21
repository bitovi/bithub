class Api::EventsController < ApplicationController
  respond_to :json

  def index
    @muster_query = request.env['muster.query']
    Rails.logger.info @muster_query

    scope = Event.scoped
    scope = scope.joins(@muster_query[:joins]) if !@muster_query[:joins].blank?
    scope = scope.includes(@muster_query[:includes]) if !@muster_query[:includes].blank?
    scope = scope.order(@muster_query[:order]) if !@muster_query[:order].blank?
    scope = scope.limit(@muster_query[:limit])
    
    if !@muster_query[:where].blank?
      tags = @muster_query[:where].values.uniq
      scope = scope.tagged_with(tags)
    end

    if false || !@muster_query[:group].blank?
      # @events = scope.nest_by(@muster_query[:group])
      # render :grouped_index
      @events = scope.nest_by(:category)
      render :json => @events
    else
      @events = scope.all    
      render :index
    end
  end

  def show
    @event = Event.find(params[:id])
    # @event = Event.includes(:category, :feed).find(params[:id])
    render :show
  end

end
