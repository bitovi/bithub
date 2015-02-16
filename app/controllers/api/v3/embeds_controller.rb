class Api::V3::EmbedsController < Api::V3::BaseController
  include Api::EmbedScoped

  before_filter :authenticate_account!
  load_and_authorize_resource

  def index
    @embeds = Embed.all
    render :index
  end

  def show
    @embed = owner_embed
    render :show
  end

  def create
    @embed = current_brand.embeds.new(embed_params)
    @embed.name = generated_name if params[:name].blank?
    @embed.save
    render :show
  end
  
  def update
    if owner_embed.update_attributes(embed_params)
      render :show
    end
  end

  def destroy
    if owner_embed.destroy
      render :json => msg_hash(@filter, 'destroy', 'success')
    else
      render :json => msg_hash(@filter, 'destroy'), :status => 406
    end
  end

  private

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
