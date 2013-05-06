class Api::EventsController < Api::ApiController
  TAG_FIELDS = ['tag', 'feed', 'category']
  DELIMITERS = { :and => ',', :or => '|', :between => ':' }
  respond_to :json

  def index
    muster_query = request.env['muster.query']
    scope = build_scope(muster_query, params)
    
    if !muster_query[:count].blank?
      render :json => { :count => scope.count(muster_query[:count]) }
    else
      scope = apply_upvote_calculation_to_scope(scope, params)
      scope = apply_order_to_scope(scope, muster_query)
      @events = EventDecorator.decorate_collection(scope.all)
      render :index
    end
  end

  def show
    @event = EventDecorator.decorate(Event.find(params[:id]))
    render :show
  end

  def create
    @event = Event.new_from_bithub(params[:event])
    @event.author = current_user
    if @event.save
      render :json => @event, :status => 200
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


  # =======> SCOPE BUILDING

  private
  def build_scope(muster_query, params)
    scope = Event.scoped ; logic_analyzer = QueryLogicAnalyzer.new(Event)
    scope = ScopeApplier.apply_muster_query_to_scope(scope, muster_query)
    scope = ScopeApplier.apply_regular_params_to_scope(logic_analyzer, scope, params)
    scope = ScopeApplier.apply_tag_based_params_to_scope(logic_analyzer, scope, params)
  end

  def apply_order_to_scope(scope, muster_query)
    if !muster_query[:order].blank?
      attribute, direction = muster_query[:order].first.split
      attribute = "total_upvotes" if attribute == "upvotes" # total_upvotes => calculated field
      scope = scope.order("#{attribute} #{direction}")
    end
    scope
  end
  
  def apply_upvote_calculation_to_scope(scope, params)
    logic_analyzer = QueryLogicAnalyzer.new(Event)
    taggables = logic_analyzer.pluck_and_process_tag_based_params(params)
    scope = scope.select_with_upvotes(taggables && !taggables[:any])
  end
end
