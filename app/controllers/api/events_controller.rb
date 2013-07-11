class Api::EventsController < Api::ApiController
  DEFAULT_CATEGORIES_TO_SUMMARZIE = ['app', 'article', 'plugin', 'code', 'chat', 'twitter', 'issues_event', 'github']
  respond_to :json
  helper_method :custom_cache_key

  rescue_from ActiveRecord::RecordNotFound, with: :show_404
  rescue_from ActiveRecord::RecordInvalid, with: :show_406

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
    e = Event.new_from_bithub(params[:event])
    e.author = current_user if !current_user.has_role?(:admin) || !posting_for_antoher_user?(params)
    if e.save
      @event = EventDecorator.decorate(e)
      render :show
    else
      render :json => { error: t('api.events.create.error'), :status => 406 }
      #render :json => e.errors.messages, :status => 406
    end
  end

  def update
    e = Event.find(params[:id])
    if e.update_from_bithub(params[:event])
      @event = EventDecorator.decorate(e)
      render :show
    else
      render :json => { error: t('api.events.update.error'), :status => 406 }
      #render :json => e.errors.messages, :status => 406
    end
  end

  def destroy
    Event.find(params[:id]).destroy
    render :json => { error: t('api.events.destroy.success') }
  end

  def summary
    cats_to_sum = params[:categories] || DEFAULT_CATEGORIES_TO_SUMMARZIE
    @summary = Hash[cats_to_sum.map{|cat| [ cat, date_filtered_sumamry(cat) ]}]
    render :summary
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

  def date_filtered_sumamry(tag)
    scope = Event.scoped.tagged_with(tag)
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

  def posting_for_antoher_user?(params)
    params[:event][:origin_author_id] &&
      !params[:event][:origin_author_id].blank? &&
      params[:event][:origin_author_feed] &&
      !params[:event][:origin_author_feed].blank?
  end
end
