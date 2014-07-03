class Api::V2::FeedConfigsController < Api::V2::BaseController
  before_filter :authenticate!

  # CanCan vs Rails4 bug, see:
  # https://github.com/ryanb/cancan/issues/835#issuecomment-21321676
  before_filter :load_config, only: :create

  load_and_authorize_resource

  def index
    @configs = current_account.brand.feed_configs.all
    render :index
  end

  def show
    @config = current_account.brand.feed_configs.find_by_id actual_params[:id]
    render :show
  end

  def create
    #@config = FeedConfig.new actual_params
    @config.brand = current_account.brand
    FeedConfigTagPlucker.new(actual_params).create_tags

    if @config.save
      render :show
    else
      render :json => msg_hash(@config, 'create'), :status => 406
    end
  end

  def update
    @config = current_account.brand.feed_configs.find_by_id params[:id]
    FeedConfigTagPlucker.new(actual_params).create_tags

    if @config && @config.update_attributes(actual_params)
      render :show
    else
      render :json => msg_hash(@config, 'update'), :status => 406
    end
  end

  def destroy
    @config = current_account.brand.feed_configs.find_by_id actual_params[:id]

    if @config.destroy
      render :json => msg_hash(@config, 'destroy', 'success')
    else
      render :json => msg_hash(@config, 'destroy'), :status => 406
    end
  end

  def tree
    @tree = Hash[Brand.all.map do |b|
      fcs = FeedConfigDecorator.decorate_collection(b.feed_configs)
      [b.name, Hash[fcs.map {|fc| [fc.feed_name, fc.config]}]]
    end]

    render :json => @tree
  end

  private

  def actual_params
    @actual ||= params.require(:feed_config).permit! #permit(:feed_name, :brand_name, :config)
    fix_params_if_broken unless @fixed
    @actual
  end

  def fix_params_if_broken
    @actual.delete(:brand_name)
    @actual[:config] = {} if @actual[:config].blank?
    @fixed = true
  end

  def load_config
    @config = FeedConfig.new actual_params
  end
end
