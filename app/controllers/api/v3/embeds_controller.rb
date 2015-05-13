class Api::V3::EmbedsController < Api::V3::BaseController
  include Api::EmbedScoped

  before_filter :authenticate_account!
  load_and_authorize_resource

  def index
    authorize! :index, Embed
    @embeds = Embed.all
    render :index
  end

  def show
    authorize! :show, owner_embed
    render :show
  end

  def create
    authorize! :create, built_embed

    @embed.name = generated_name if params[:name].blank?

    permited = Subscriptions::PolicyChecker
      .new(current_brand.organization.subscription)
      .can_create_embed?(current_brand)

    if permited
      if @embed.save
        render :show
      else
        render :json => msg_hash(@embed, 'create'), :status => 422
      end
    else
      render :json => msg_hash(@embed, 'create'), :status => 406
    end
  end

  def update
    authorize! :update, owner_embed

    if @embed.update_attributes(embed_params)
      render :show
    end
  end

  def destroy
    authorize! :destroy, owner_embed

    if @embed.clear_relations_and_destroy
      render :json => msg_hash(@embed, 'destroy', 'success'), :status => 204
    else
      render :json => msg_hash(@embed, 'destroy'), :status => 406
    end
  end

  def moderate
    authorize! :moderate, owner_embed

    if @embed.moderate
      render :json => msg_hash(@embed, 'moderate')
    else
      render :json => msg_hash(@embed, 'moderate', 'error')
    end
  end

  private

  def built_embed
    @embed = current_brand.embeds.build(embed_params)
  end

  def embed_params
    params.require(:embed).permit(:name, :colorscheme, :layout, :approved_by_default)
  end

  def generated_name
    Bazaar.heroku
  end

  def embed_id
    params[:id]
  end
end
