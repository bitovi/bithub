class Api::UsersController < ApplicationController
  respond_to :json
  rescue_from ActiveRecord::RecordInvalid, :with => :show_errors
  rescue_from ActiveRecord::RecordNotFound, :with => :show_errors


  def index
    @muster_query = request.env['muster.query']
    Rails.logger.info @muster_query

    scope = User.scoped
    scope = scope.joins(@muster_query[:joins]) if !@muster_query[:joins].blank?
    scope = scope.includes(@muster_query[:includes]) if !@muster_query[:includes].blank?
    scope = scope.order(@muster_query[:order]) if !@muster_query[:order].blank?
    scope = scope.offset(@muster_qu1gtery[:offset]) if !@muster_query[:offset].blank?
    scope = scope.limit(@muster_query[:limit])
    scope = scope.where(attr_queries(params))
    
    @users = scope.all
    @users = UserDecorator.decorate_collection(@users)
    render :index
  end

  def show
    @user = User.find(params[:id])
    render :show
  end

  def activities
    @activities = ActivityDecorator.decorate_collection(User.find(params[:user_id]).activities)
    render 'api/activities/index'
  end

  def events
    @events = EventDecorator.decorate_collection(User.find(params[:user_id]).events)
    render 'api/events/index'
  end
  
  private
  def attr_queries(params)
    h = Hash.new
    params.each do |k,v|
      h[k] = v if User.has_an_attribute?(k)
    end
    return h
  end
end
