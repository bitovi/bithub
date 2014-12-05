require 'securerandom'

class Api::V3::EmbedsController < Api::V3::BaseController
  before_filter :authenticate!
  load_and_authorize_resource

  def index
    @embeds = Embed.all
    render :index
  end

  def show
    @embed = current_brand.embeds.find(params[:id])
    render :show
  end

  def create
    @embed = current_brand.embeds.create(embed_params)
    @embed.name = generated_name if params[:name].blank?
    render :show
  end
  
  def update
    @embed = current_brand.embeds.find(params[:id])
    if @embed.update_attributes(embed_params)
      render :show
    end
  end

  def destroy
    @embed = current_brand.embeds.find(params[:id])

    if @embed.destroy
      render :json => msg_hash(@filter, 'destroy', 'success')
    else
      render :json => msg_hash(@filter, 'destroy'), :status => 406
    end
  end

  private

  def embed_params
    params.require(:embed).permit(:name, :colorscheme, :layout)
  end

  def generated_name
    SecureRandom.hex
  end
end
