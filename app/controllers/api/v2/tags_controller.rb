class Api::V2::TagsController < Api::V2::BaseController
  before_filter :authenticate!
  load_and_authorize_resource

  def index
    mq = request.env['muster.query']

    # override default limit (50)
    mq['limit'] = 1000 if mq['limit'].to_i < 1000

    scope = build_scope(mq, params)
    scope = scope.tagged_with(params[:type].pluralize) if params[:type]

    @tags = scope.all

    render :index
  end

  def show
    @tag = Tag.find(params[:id])
    render :show
  end

  def create
    @tag = Tag.new(params[:tag])

    if @tag.save
      render :show
    else
      render :json => msg_hash(@tag, 'create'), :status => 406
    end
  end

  def update
    @tag = Tag.find(params[:id])

    if @tag.update_attributes(params[:tag])
      render :show
    else
      render :json => msg_hash(@tag, 'update'), :status => 406
    end
  end

  def destroy
    @tag = Tag.find(params[:id])

    if @tag.destroy
      render :json => msg_hash(@tag, 'destroy', 'success'), :status => 200
    else
      render :json => msg_hash(@tag, 'destroy'), :status => 406
    end
  end


  # SCOPE BUILDING
  # --------------

  def query_logic(params)
    @logic_analyzer ||= QueryLogic::Query.new(Tag, params)
  end

  def scope_applier(params, current_scope = nil)
    @scope_applier ||= ScopeApplier.new(current_scope || Tag, query_logic(params))
  end

  def build_scope(muster_query, params)
    scope = Tag

    scope_applier(params, scope)
    .apply_muster_query_to_scope(muster_query)
    .result
  end
end
