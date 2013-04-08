class Api::UsersController < ApplicationController
  respond_to :json
  #rescue_from ActiveRecord::RecordInvalid, :with => :show_errors
  #rescue_from ActiveRecord::RecordNotFound, :with => :show_errors

  def index
    @muster_query = request.env['muster.query']
    Rails.logger.info @muster_query
    pluck_virtual_attrs(@muster_query[:order])

    scope = User.scoped
    scope = scope.joins(@muster_query[:joins]) if !@muster_query[:joins].blank?
    scope = scope.includes(@muster_query[:includes]) if !@muster_query[:includes].blank?
    scope = scope.order(filter_order_query(@muster_query[:order])) if !@muster_query[:order].blank?
    scope = scope.offset(@muster_query[:offset]) if !@muster_query[:offset].blank?
    scope = scope.limit(@muster_query[:limit])
    scope = scope.where(attr_queries(params))
    
    # Ordering by virtual calculated attributes (only first one matters currently)
    va = pluck_virtual_attrs(@muster_query[:order])
    if va
      name, direction = va.split
      Rails.logger.info "#{name} ::::::: #{direction}"
      @users = scope.all.sort{|u1, u2| u1.send(name) <=> u2.send(name)}
      @users.reverse! if direction == "desc"
    else
      @users = scope.all
    end
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

  def top
    @users = User.top(params[:n] || 10)
    @users = UserDecorator.decorate_collection(@users)
    render :index
  end
  
  private
  def attr_queries(params)
    h = Hash.new
    params.each do |k,v|
      h[k] = v if User.has_an_attribute?(k)
    end
    return h
  end

  private

  def filter_order_query(query)
    query.reject{|p| !User.has_an_attribute?(p.split[0])}
  end

  def pluck_virtual_attrs(query)
    query.select{|p| !User.has_an_attribute?(p.split[0])}[0]
  end

end
