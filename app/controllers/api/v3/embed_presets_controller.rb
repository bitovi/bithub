require 'digest/md5'

class Api::V3::EmbedPresetsController < Api::V3::BaseController
  before_filter :authenticate_account!

  def index
    @presets = owner_embed.presets.all
    render :index
  end

  def show
    @preset = find_preset
    render :show
  end

  def create
    if (@preset = owner_embed.presets.create(embed_preset_params))
      render :show
    else
      render :json => msg_hash(@preset, 'create'), :status => 406
    end
  end

  def destroy
    preset = find_preset
    if (@preset.destroy)
      render :json => msg_hash(@preset, 'destroy', 'success')
    else
      render :json => msg_hash(@preset, 'destroy'), :status => 406
    end
  end

  private

  def owner_embed
    current_brand.embeds.find(embed_id)
  end

  def find_preset
    owner_embed.presets.find(preset_id)
  end
  
  def embed_preset_params
    params.require(:preset).permit(:name, :json, :embed_id)
  end

  def preset_id
    params[:preset_id] || params[:id]
  end

  def embed_id
    params[:embed_id]
  end
end
