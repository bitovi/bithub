class Api::V1::TagsController < Api::V1::BaseController
  before_filter :authenticate_user!, except: [:index, :show]
  load_and_authorize_resource
  skip_load_and_authorize_resource only: [:index, :show]

  respond_to :json

  rescue_from ActiveRecord::RecordNotFound, with: :show_404
  rescue_from ActiveRecord::RecordInvalid, with: :show_406
  rescue_from CanCan::AccessDenied, with: :show_401

  def index

    mq = request.env['muster.query']

    # overridedefault limit (50)
    mq['limit'] = 1000 if mq['limit'] < 1000

    scope = build_scope(mq, params)
    scope = scope.tagged_with(params[:type].pluralize) if params[:type]

    # replace ordering by priority if any
    if order_by_priority = mq['order'].select {|o| o.starts_with? 'priority'}.first
      order_by_priority.gsub! /priority/, "CASE WHEN (props -> 'priority') IS NULL THEN 0 ELSE (props -> 'priority')::integer END"
      scope = scope.order(order_by_priority)
    end

    @tags = scope.all

    render :index
  end

  def show
    @tag = Tag.find(params[:id])
    render :show
  end

  def create
    authorize! :manage, Tag, :message => "No rights to manage tags."
    @tag = Tag.new(params[:tag])
    if @tag.save
      render :show
    else
      render :json => msg_hash(@tag, 'create'), :status => 406
    end
  end

  def update
    authorize! :manage, Tag, :message => "No rights to manage tags."
    @tag = Tag.find(params[:id])
    if @tag.update_attributes(params[:tag])
      render :show
    else
      render :json => msg_hash(@tag, 'update'), :status => 406
    end
  end

  def destroy
    authorize! :manage, Tag, :message => "No rights to manage tags."
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
    @scope_applier ||= ScopeApplier.new(current_scope || Tag.scoped, query_logic(params))
  end

  def build_scope(muster_query, params)
    scope = Tag.scoped

    scope_applier(params, scope)
    .apply_muster_query_to_scope(muster_query)
    .result
  end
end
