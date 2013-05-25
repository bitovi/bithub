class Api::EventsController < Api::ApiController
  respond_to :json

  def index
    muster_query = request.env['muster.query']
    scope = build_scope(muster_query, params)
    
    if !muster_query[:count].blank?
      render :json => { :count => scope.count(muster_query[:count]) }
    else
      scope = apply_upvote_calculation_to_scope(scope, params)
      scope = scope_applier.apply_order_to_scope(scope, muster_query)
      @events = EventDecorator.decorate_collection(scope.all, {
        context: { excluded_attributes: logic_analyzer.pluck_excluded_attributes(params) }
      })
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
    if @event.update_from_bithub!(params[:event])
      render :status => 200
    else
      render :json => @event.errors.messages, :status => 500
    end
  end

  private # SCOPE BUILDING
  def build_scope(muster_query, params)
    scope = Event.scoped
    scope = scope.includes(:children)
    scope = scope_applier.apply_negated_attrs_to_scope(scope, params)
    scope = scope_applier.apply_muster_query_to_scope(scope, muster_query)
    scope = scope_applier.apply_regular_params_to_scope(scope, params)
    scope = scope_applier.apply_tag_based_params_to_scope(scope, params)
  end

  def apply_upvote_calculation_to_scope(scope, params)
    taggables = logic_analyzer.pluck_and_process_tag_based_params(params)
    scope = scope.select_with_upvotes(taggables && !taggables[:any])
  end

  def logic_analyzer
    @logic_analyzer ||= QueryLogicAnalyzer.new(Event)
  end

  def scope_applier
    @scope_applier ||= ScopeApplier.new(logic_analyzer) 
  end
end
