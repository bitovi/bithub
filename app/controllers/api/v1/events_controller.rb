require 'digest/md5'

class Api::V1::EventsController < Api::V1::BaseController
  before_filter :authenticate_user!, except: [:index, :show, :summary, :pagination]
  
  respond_to :json
  helper_method :custom_cache_key
  helper_method :list_cache_key

  rescue_from ActiveRecord::RecordNotFound, with: :show_404
  rescue_from ActiveRecord::RecordInvalid, with: :show_406
  rescue_from CanCan::AccessDenied, with: :show_401
    
  DEFAULT_CATEGORIES_TO_SUMMARZIE = ['app', 'article', 'plugin', 'code', 'chat', 'twitter', 'issues_event', 'github', 'question']
  POSSIBLE_ISSUE_STATES = ['open', 'closed']

  def index
    muster_query = request.env['muster.query']
    scope = build_scope(muster_query, params)
    
    if !muster_query[:count].blank?
      render :json => { :count => scope.count(muster_query[:count]) }
    else
      @events = EntityDecorator.decorate_collection(scope.all, {
        context: { excluded_attributes: query_logic(params).exclusions }
      })
      @ev_relations = EntityRelations.new(@events.map{|e| e.id })
      render 'api/v1/events/index'
    end
  end

  def show
    @event = EntityDecorator.decorate(Entity.find(params[:id]))
    @ev_relations = EntityRelations.new(@event.id)
    render :show
  end

  def create
    e = Entity.new_from_bithub(params[:event])
    e.author = current_user if !current_user.has_role?(:admin) || !posting_for_antoher_user?(params)
    if e.save
      e.bump_thread
      @event = EntityDecorator.decorate(e)
      @ev_relations = EntityRelations.new(@event.id)
      render :show
    else
      render :json => msg_hash(e, 'events', 'create'), :status => 406
    end
  end

  def update
    authorize! :manage, Entity, :message => "No rights to manage events."
    e = Entity.find(params[:id])
    if e.update_from_bithub(params[:event])
      @event = EntityDecorator.decorate(e)
      @ev_relations = EntityRelations.new(@event.id)
      render :show
    else
      render :json => msg_hash(e, 'events', 'update'), :status => 406
    end
  end

  def destroy
    authorize! :manage, Entity, :message => "No rights to manage events."
    Entity.find(params[:id]).destroy
    render :json => { error: t('api.events.destroy.success') }
  end

  def summary
    cats_to_sum = params[:categories] || DEFAULT_CATEGORIES_TO_SUMMARZIE
    @summary = Hash[cats_to_sum.map{|cat| [cat, date_filtered_sumamry(cat, params)]}]
    render :summary
  end

  def pagination
    summary = Pagination.grouped
    render :json => summary
  end

  private # SCOPE BUILDING

  def build_scope(muster_query, params)
    scope = Entity.scoped_with_includes
    scope = scope.not_children if !counting?
    scope = scope.no_irc_nor_digest if on_greatest?
    scope = scope.with_state(params[:state]) if POSSIBLE_ISSUE_STATES.include?(params[:state])

    scope_applier(params, scope)
    .apply_negated_attrs_to_scope
    .apply_muster_query_to_scope(muster_query)
    .apply_regular_params_to_scope
    .apply_tag_based_params_to_scope
    .apply_order_to_scope
    .result
  end

  def query_logic(params)
    @query_logic ||= QueryLogic::Query.new(Entity, params)
  end

  def scope_applier(params, current_scope = nil)
    ScopeApplier.new((current_scope || Entity.scoped), query_logic(params))
  end

  def date_filtered_sumamry(tag, params)
    scope = Entity.scoped.tagged_with(tag)

    scope_applier(scope, params)
    .apply_tag_based_params_to_scope
    .apply_regular_params_to_scope
    .result.count
  end

  def custom_cache_key(event)
    qs  = CGI.parse(request.query_string)
    key = [event.cache_key]
    if !qs.blank?
      event_params = qs.reject{|k, v| !['exclude', 'include'].include?(k)}
      key << fragment_cache_key(event_params.sort) unless event_params.blank?
    end
    key.join('/')
  end

  def list_cache_key(events)
    qs  = CGI.parse(request.query_string)
    key = [events.map{|ev| ev.cache_key}.join("|")]
    if !qs.blank?
      key.unshift(fragment_cache_key(qs.sort))
    end
    Digest::MD5.hexdigest(key.join(':'))
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
