class Api::V2::TagsController < Api::V2::BaseController
  before_filter :authenticate_user!, except: [:index, :show, :tree]
  load_and_authorize_resource
  skip_load_and_authorize_resource only: [:index, :show, :tree]

  respond_to :json

  rescue_from ActiveRecord::RecordNotFound, with: :show_404
  rescue_from ActiveRecord::RecordInvalid, with: :show_406
  rescue_from CanCan::AccessDenied, with: :show_401

  def index
    mq = request.env['muster.query']

    # override default limit (50)
    mq['limit'] = 1000 if mq['limit'].to_i < 1000

    scope = build_scope(mq, params)
    scope = scope.tagged_with(params[:group]) if params[:group]

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

  ### Non-CRUD endpoints

  def tree
    keywords = Tag.tagged_with('keywords').pluck(:name) \
             + Tag.tagged_with('projects').pluck(:name)

    feeds = Tag.tagged_with("feeds").map do |f|
      types = Tag.tagged_with("types,#{f.name}").map do |t|
        specifics = Tag.tagged_with("#{f.name},#{t.name},feed_specifics").pluck :name
        {name: t.name, specifics: specifics}
      end

      {name: f.name, types: types}
    end

    @tree = {
      feeds: feeds,
      keywords: keywords
    }

    render :tree
  end

  private



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
