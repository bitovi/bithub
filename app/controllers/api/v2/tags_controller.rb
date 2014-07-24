class Api::V2::TagsController < Api::V2::BaseController
  before_filter :authenticate!
  load_and_authorize_resource except: [:tree]

  def index
    mq = request.env['muster.query']

    # override default limit (50)
    mq['limit'] = 1000 if mq['limit'].to_i < 1000

    scope = build_scope(mq, params)
    scope = scope.tagged_with(params[:type].pluralize) if params[:type]
    @tags = scope.all
    @tags_count = build_scope_for_counting(mq).count

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

  ### Non-CRUD endpoints

  def tree
    authorize! :read_tags_tree, Tag, :message => "No right to read tag tree!"
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
    @scope_applier ||= ScopeApplier.new(current_scope || Tag, query_logic(params))
  end

  def build_scope(muster_query, params)
    scope_applier(params, Tag)
    .apply_muster_query_to_scope(muster_query)
    .result
  end

  def build_scope_for_counting(muster_query)
    scope_applier(Tag)\
      .apply_muster_query_to_scope(muster_query, skip_limits: true)\
      .apply_negated_attrs_to_scope\
      .apply_existence_attrs_to_scope\
      .apply_regular_params_to_scope\
      .result.offset(0).limit(1_000_000_000)
  end
end
