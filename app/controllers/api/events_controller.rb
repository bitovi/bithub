class Api::EventsController < ApplicationController
  TAG_FIELDS = ['tag', 'feed', 'category']
  respond_to :json
  before_filter :authenticate_user!, :only => ['create', 'update']

  def index
    @muster_query = request.env['muster.query']
    Rails.logger.info @muster_query

    scope = Event.includes(:tags).scoped
    scope = scope.joins(@muster_query[:joins]) if !@muster_query[:joins].blank?
    scope = scope.includes(@muster_query[:includes]) if !@muster_query[:includes].blank?
    scope = scope.order(@muster_query[:order]) if !@muster_query[:order].blank?
    scope = scope.offset(@muster_query[:offset]) if !@muster_query[:offset].blank?
    scope = scope.limit(@muster_query[:limit])
    scope = scope.where(all_others(params))
    scope = scope.tagged_with(only_tags(params)) if !only_tags(params).empty?
    
    @events = scope.all
    @events = EventDecorator.decorate_collection(@events)

    render :index
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

  private

  def only_tags(params)
    params.find_all{|el| TAG_FIELDS.include?(el[0])}.map{|el| el[1]}.flatten
  end

  def all_others(params)
    h = Hash.new
    params.each do |k,v|
      h[k] = v if Event.has_an_attribute?(k) && !TAG_FIELDS.include?(k)
    end
    return h
  end

end
