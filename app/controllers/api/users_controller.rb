class Api::UsersController < Api::ApiController
  respond_to :json

  def index
    muster_query = request.env['muster.query']
    scope = build_scope(muster_query, params)
    
    # Ordering by virtual calculated attributes (can order by only one attr)
    virtual_attrs = take_first(pluck_virtual_attrs(muster_query[:order]))
    if virtual_attrs
      attribute, direction = virtual_attrs.split
      @users = scope.all.sort{|u1, u2| u1.send(attribute) <=> u2.send(attribute)}
      @users.reverse! if direction == "desc"
    else
      scope = scope.order(filter_order_query(muster_query[:order])) if !muster_query[:order].blank?
      @users = scope.all
    end
    @users = UserDecorator.decorate_collection(@users)
    render :index
  end

  def show
    @user = UserDecorator.decorate(User.find(params[:id]))
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

  private
  def build_scope(muster_query, params)
    scope = User.scoped ; logic_analyzer = QueryLogicAnalyzer.new(User)
    scope = ScopeApplier.apply_muster_query_to_scope(scope, muster_query)
    scope = ScopeApplier.apply_regular_params_to_scope(logic_analyzer, scope, params)
    scope
  end
  
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
