class Api::EventsController < Api::ApiController
  before_filter :authenticate_user!, except: [:index, :show, :summary]
  
  respond_to :json
  helper_method :custom_cache_key

  rescue_from ActiveRecord::RecordNotFound, with: :show_404
  rescue_from ActiveRecord::RecordInvalid, with: :show_406
  rescue_from CanCan::AccessDenied, with: :show_401
		
  DEFAULT_CATEGORIES_TO_SUMMARZIE = ['app', 'article', 'plugin', 'code', 'chat', 'twitter', 'issues_event', 'github', 'question']
  CATEGORIES_NAME_ORDER = YAML::load_file('config/categories_order.yml')['categories']
  CATEGORIES_ID_ORDER = CATEGORIES_NAME_ORDER.map{|el| Tag.where("name = ?", el).pluck(:id)}.flatten
  POSSIBLE_ISSUE_STATES = ['open', 'closed']

  def index
    muster_query = request.env['muster.query']
    scope = build_scope(muster_query, params)
    
    if !muster_query[:count].blank?
      render :json => { :count => scope.count(muster_query[:count]) }
    else
      scope = apply_upvote_calculation_to_scope(scope, params)
      scope = scope_applier.apply_order_to_scope(scope, params, CATEGORIES_ID_ORDER)
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
    e = Event.new_from_bithub(params[:event])
    e.author = current_user if !current_user.has_role?(:admin) || !posting_for_antoher_user?(params)
    if e.save
      e.bump_thread
      @event = EventDecorator.decorate(e)
      render :show
    else
      render :json => msg_hash(e, 'events', 'create'), :status => 406
    end
  end

  def update
    authorize! :manage, Event, :message => "No rights to manage events."
    e = Event.find(params[:id])
    if e.update_from_bithub(params[:event])
      @event = EventDecorator.decorate(e)
      render :show
    else
      render :json => msg_hash(e, 'events', 'update'), :status => 406
    end
  end

  def destroy
    authorize! :manage, Event, :message => "No rights to manage events."
    Event.find(params[:id]).destroy
    render :json => { error: t('api.events.destroy.success') }
  end

  def summary
    cats_to_sum = params[:categories] || DEFAULT_CATEGORIES_TO_SUMMARZIE
    @summary = Hash[cats_to_sum.map{|cat| [cat, date_filtered_sumamry(cat, params)]}]
    render :summary
  end

  private # SCOPE BUILDING
  def build_scope(muster_query, params)
    scope = Event.scoped
    scope = scope.includes(:children)
    scope = scope.not_children if !counting?
    scope = scope.no_irc if on_greatest?
    scope = scope.with_state(params[:state]) if POSSIBLE_ISSUE_STATES.include?(params[:state])
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

  def date_filtered_sumamry(tag, params)
    scope = Event.scoped.tagged_with(tag)
    scope = scope_applier.apply_tag_based_params_to_scope(scope, params)
    scope = scope_applier.apply_regular_params_to_scope(scope, params)
    scope.count
  end

  def custom_cache_key(event)
    qs = CGI.parse(request.query_string)
    if !qs.blank?
      event.cache_key + '/' + fragment_cache_key(qs.sort)
    else
      event.cache_key
    end
  end

  def counting?
    params['count'] || request.env['muster.query']['count']
  end

  def on_greatest?
    params['order'] =~ /upvotes/
  end

  def posting_for_antoher_user?(params)
    params['postas'] && !params['postas'].blank?
  end
end
