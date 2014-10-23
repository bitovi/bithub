class Api::V3::EmbedsController < Api::V2::BaseController
  before_filter :authenticate!

  def index
    @embeds = Embed.all
    render :index
  end
  
  def show
    @embed = current_brand.embeds.where(id: params[:id]).first
    render :show
  end

  def create
    @embed = current_brand.embeds.create(embed_params)
    render :show
  end

  private
  def embed_params
    params.require(:embed).permit(:name, :colorscheme, :layout)
  end
end
