require 'digest/md5'

class Api::V3::EmbedPresetsController < Api::V3::BaseController
  include Api::EmbedScoped

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
    if (@preset = EmbedPreset.create(embed_preset_params))
      render :show
    else
      render :json => msg_hash(@preset, 'create'), :status => 406
    end
  end

  def destroy
    @preset = find_preset
    if (@preset.destroy)
      render :json => msg_hash(@preset, 'destroy', 'success')
    else
      render :json => msg_hash(@preset, 'destroy'), :status => 406
    end
  end

  private

  def find_preset
    EmbedPreset.find(preset_id)
  end
  
  def embed_preset_params
    params.require(:preset).permit(:name, :embed_id, config: [:live, :theme])
  end

  def preset_id
    params[:preset_id] || params[:id]
  end
end
