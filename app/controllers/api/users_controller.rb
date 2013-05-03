class Api::UsersController < Api::ApiController
  respond_to :json
  rescue_from ActiveRecord::RecordInvalid, :with => :show_errors
  rescue_from ActiveRecord::RecordNotFound, :with => :show_errors

  def index
    @muster_query = request.env['muster.query']
    Rails.logger.info @muster_query

    scope = User.scoped
    scope = scope.joins(@muster_query[:joins]) if !@muster_query[:joins].blank?
    scope = scope.includes(@muster_query[:includes]) if !@muster_query[:includes].blank?
    scope = scope.order(filter_order_query(@muster_query[:order])) if !@muster_query[:order].blank?
    scope = scope.offset(@muster_query[:offset]) if !@muster_query[:offset].blank?
    scope = scope.limit(@muster_query[:limit])
    scope = scope.where(attr_queries(params))
    
    # Ordering by virtual calculated attributes (can order by only one attr)
    va = take_first(pluck_virtual_attrs(@muster_query[:order]))
    if va
      name, direction = va.split
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

  def update
    filtered_params = params.select {|param| User.accessible_attributes.include?(param)}

    if params[:countryISO]
      country = Country.where({:iso => params[:countryISO]}).first
      filtered_params[:country] = country if country
    end

    if User.update(params[:id], filtered_params)
      render :status => 200, :json => {:id => params[:id]}
    else
      render :json => @event.errors.messages, :status => 500
    end
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

  private

  def take_first(query)
    query[0]
  end

  def filter_order_query(query)
    query.reject{|p| !User.has_an_attribute?(p.split[0])}
  end

  def pluck_virtual_attrs(query)
    query.select{|p| !User.has_an_attribute?(p.split[0])}
  end

end
