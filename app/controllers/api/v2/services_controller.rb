class Api::V2::ServicesController < Api::V2::BaseController
  before_filter :authenticate!

  # CanCan vs Rails4 bug, see:
  # https://github.com/ryanb/cancan/issues/835#issuecomment-21321676
  before_filter :load_config, only: :create

  load_and_authorize_resource except: [:tree]

  def index
    @services = current_brand.services.all
    render :index
  end

  def show
    @config = current_brand.services.find_by_id actual_params[:id]
    render :show
  end

  def create
    @config.brand = current_account.brand
    create_tags(FeedConfigTagPlucker.new(actual_params).tags)

    if @config.save
      render :show
    else
      render :json => msg_hash(@config, 'create'), :status => 406
    end
  end

  def update
    @service = current_account.brand.services.find_by_id params[:id]
    create_tags(FeedConfigTagPlucker.new(actual_params).tags)

    if @service && @service.update_attributes(actual_params)
      render :show
    else
      render :json => msg_hash(@service, 'update'), :status => 406
    end
  end

  def destroy
    @config = current_account.brand.services.find_by_id actual_params[:id]

    if @service.destroy
      render :json => msg_hash(@service, 'destroy', 'success')
    else
      render :json => msg_hash(@service, 'destroy'), :status => 406
    end
  end

  def tree
    # used by crawler!
    authorize! :read, FeedConfig if request.ip != '127.0.0.1'

    @tree = Hash[Brand.all.map do |brand|
      services = ServiceDecorator.decorate_collection(brand.services)
      [b.name, Hash[
        services.reject do |s|
          s.config.empty?
        end.map do |fc|
          [s.feed_name, s.config.to_h]
      end]]
    end]

    render :json => @tree
  end

  private

  def create_tags(tags)
    tags.andand.each do |t|
      Tag.register t, 'keywords'
    end
  end

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
