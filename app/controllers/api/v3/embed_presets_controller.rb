require 'digest/md5'

class Api::V3::EmbedPresetsController < Api::V3::BaseController
  include Api::EmbedScoped

  before_filter :authenticate_account!

  def index
    authorize! :index, EmbedPreset
    all_presets
    render :index
  end

  def show
    authorize! :show, a_preset
    render :show
  end

  def create
    authorize! :create, EmbedPreset

    if @preset = EmbedPreset.create(embed_preset_params)
      render :show
    else
      render :json => msg_hash(@preset, 'create'), :status => 422
    end
  end

  def update
    authorize! :update, a_preset

    if @preset.update_attributes(embed_preset_params)
      render :show
    else
      render :json => msg_hash(@preset, 'update'), :status => 422
    end
  end

  def destroy
    authorize! :destroy, a_preset
    if @preset.destroy
      render :json => msg_hash(EmbedPreset, 'destroy', 'success'), :status => 204
    else
      render :json => msg_hash(EmbedPreset, 'destroy'), :status => 422
    end
  end

  private
  def all_presets
    @presets = owner_embed.presets.all
  end

  def a_preset
    @preset = EmbedPreset.find(preset_id)
  end

  def embed_preset_params
    params.require(:preset).permit(:name, :embed_id, config: [:live, :theme])
  end

  def preset_id
    params[:preset_id] || params[:id]
  end
end
