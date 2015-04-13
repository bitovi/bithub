class Api::V3::FiltersController < Api::V3::BaseController
  include Api::EmbedScoped

  before_filter :authenticate_account!

  def index
    embed = current_brand.embeds.find(embed_id)
    @filters = embed.filters
    render 'api/v3/filters/index'
  end

  def show
    embed = current_brand.embeds.find(embed_id)
    @filter = embed.filters.find(filter_id)
    if @filter
      render 'api/v3/filters/show'
    else
      render :json => msg_hash(@filter, 'show'), :status => 404
    end
  end

  def create
    @filter = owner_embed.filters.build(filter_params)
    @filter.natlang_queries.build(queries_params)

    if owner_embed.save && @filter.save
      render 'api/v3/filters/show'
    else
      render :json => msg_hash(@filter, 'create'), :status => 406
    end
  end

  def update
    # TODO
  end

  def destroy
    embed = current_brand.embeds.find(embed_id)
    @filter = embed.filters.find(filter_id)

    if @filter.destroy
      render :json => msg_hash(@filter, 'destroy', 'success')
    else
      render :json => msg_hash(@filter, 'destroy'), :status => 406
    end
  end

  private

  def embed_id
    params[:embed_id] || params[:filter].andand[:embed_id]
  end

  def filter_id
    params[:filter_id] || params[:id]
  end

  def filter_params
    @json ||= ActionController::Parameters.new(JSON.parse_nil(request.body.read))
    @json.require(:filter).permit(:id, :action, :embed_id)
  end

  def queries_params
    @json ||= ActionController::Parameters.new(JSON.parse_nil(request.body.read))
    @json.require(:filter).permit(natlang_queries: %i(is_negated attr_name op val)).require(:natlang_queries)
  end
end
