class Api::EventsController < ApplicationController
  respond_to :json
  protect_from_forgery :except => [:create, :update]

  def index
    @muster_query = request.env['muster.query']
    Rails.logger.info @muster_query

    scope = Event.includes(:tags).scoped
    scope = scope.joins(@muster_query[:joins]) if !@muster_query[:joins].blank?
    scope = scope.includes(@muster_query[:includes]) if !@muster_query[:includes].blank?
    scope = scope.order(@muster_query[:order]) if !@muster_query[:order].blank?
    scope = scope.offset(@muster_qu1gtery[:offset]) if !@muster_query[:offset].blank?
    scope = scope.limit(@muster_query[:limit])
    
    if !@muster_query[:where].blank?
      tags = @muster_query[:where].values.uniq
      scope = scope.tagged_with(tags)
    end

    if !@muster_query[:group].blank?
      @decorated_events_in_groups = Hash[scope.nest_by(@muster_query[:group]).map {|group, coll| [group, EventDecorator.decorate_collection(coll)] }]
      render :grouped_index
    else
      @events = scope.all
      @events = EventDecorator.decorate_collection(@events)
      render :index
    end
  end

  def show
    @event = EventDecorator.decorate(Event.find(params[:id]))
    render :show
  end

  def create
    @event = Event.new(params[:event])
    if @event.save
      render :status => 200
    else
      render :json => @event.errors.messages, :status => 500
    end
  end

  def update
    @event = Event.find(params[:id])
    if Event.update(params[:event])
      render :status => 200
    else
      render :json => @event.errors.messages, :status => 500
    end
  end

end
