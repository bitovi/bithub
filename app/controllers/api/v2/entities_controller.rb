require 'digest/md5'

class Api::V2::EntitiesController < Api::V2::BaseController
  before_filter :authenticate!

  load_and_authorize_resource
  skip_load_and_authorize_resource :only => :pagination

  helper_method :custom_cache_key
  helper_method :list_cache_key

  # DEFAULT_CATEGORIES_TO_SUMMARIZE = ['app', 'article', 'plugin', 'code', 'chat', 'twitter', 'issues_event', 'github', 'question']
  POSSIBLE_ISSUE_STATES = ['open', 'closed']

  def index
    set_params

    muster_query = request.env['muster.query']
    scope = build_scope(muster_query, params)

    if !muster_query[:count].blank?
      render :json => { :count => scope.count(muster_query[:count]) }
    else
      @entities = EntityDecorator.decorate_collection(scope.all, {
        context: { excluded_attributes: query_logic(params).exclusions }
      })
      @ev_relations = EntityRelations.new(@entities.map{|e| e.id })
      render 'api/v2/entities/index'
    end
  end

  def show
    @entity = EntityDecorator.decorate(Entity.find(params[:id]))
    @ev_relations = EntityRelations.new(@entity.id)
    render :show
  end

  def create
    create_or_update
  end

  def update
    create_or_update
  end

  def destroy
    Entity.find(params[:id]).destroy
    render :json => { error: t('api.entities.destroy.success') }
  end

  # Do we need this? --> used only on canjs.com
  #
  # def summary
  #   cats_to_sum = params[:categories] || DEFAULT_CATEGORIES_TO_SUMMARIZE
  #   @summary = Hash[cats_to_sum.map{|cat| [cat, date_filtered_summary(cat, params)]}]
  #   render :summary
  # end

  def pagination
    authorize! :read_pagination, Pagination

    params[:clientTz] = request.headers['clientTz'] unless params[:clientTz]
    @dates = Pagination.grouped(params)

    render :pagination_index
  end

  private # SCOPE BUILDING

  def set_params
    params[:clientTz] = request.headers['clientTz'] unless params[:clientTz]
    params[:order] = "thread_updated_ts:asc"  if params[:order] == "thread_updated_at:asc"
    params[:order] = "thread_updated_ts:desc" if params[:order] == "thread_updated_at:desc"
  end

  def create_or_update
    method        = params[:id].nil?? 'create' : 'update'
    event, entity = Entities::Bithub::Post.forge(params, current_user)

    errors = [event, entity].compact.reduce({}) do |memo, model|
      memo.merge model.errors
    end

    errors.delete(:base) if errors[:base].blank?

    if errors.blank?
      @entity = EntityDecorator.decorate(entity)
      @ev_relations = EntityRelations.new(@entity.id)

      # if author = @event.author
      #   Upvote.create_based_on_rule(User.find(author.id), @event) if author.id.is_a? Integer
      # end

      render :show
    else
      render :json => {
        message: t("api.entities.#{method}.error"),
        errors:  errors
      }, :status => 406
    end
  end

  def build_scope(muster_query, params)
    scope = Entity.scoped_with_includes
    scope = scope.no_children if !counting?
    scope = scope.no_feed('irc').no_category('digest') if on_greatest?
    scope = scope.with_state(params[:state]) if POSSIBLE_ISSUE_STATES.include?(params[:state])

    scope = scope.no_type(params[:no_feed]) if params[:no_feed].present?
    scope = scope.no_type(params[:no_type]) if params[:no_type].present?
    scope = scope.no_type(params[:no_category]) if params[:no_category].present?

    if params[:without_future].present?
      scope = scope.without_future(params[:clientTz] || 'UTC')
    end

    if params[:in_future].present?
      scope = scope.in_future(params[:clientTz] || 'UTC')
    end

    if params[:author_id].present?
      scope = scope.joins(:ownerships)
           .where("ownerships.ownership_type = 'author' AND ownerships.owner_id = ?", params[:author_id])
    end

    if params[:host_id].present?
      scope = scope.joins(:ownerships)
           .where("ownerships.ownership_type = 'host' AND ownerships.owner_id = ?", params[:host_id])
    end

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

  def date_filtered_summary(tag, params)
    scope = Entity.scoped.tagged_with(tag)

    scope_applier(params, scope)
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

end
