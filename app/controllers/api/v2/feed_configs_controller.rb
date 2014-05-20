class Api::V2::FeedConfigsController < Api::V2::BaseController
  respond_to :json
  # before_filter :check_token, :only => :tree

  rescue_from ActiveRecord::RecordNotFound, with: :show_404
  rescue_from ActiveRecord::RecordInvalid, with: :show_406

  def index
    @configs = current_account.brand.feed_configs.all
    render :index
  end

  def show
    @config = current_account.brand.feed_configs.find_by_id params[:id]
    render :show
  end

  def create
    @config = FeedConfig.new(actual_params)
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
    @config = current_account.brand.feed_configs.find_by_id params[:id]
    if @config.destroy
      render :json => msg_hash(@config, 'destroy', 'success')
    else
      render :json => msg_hash(@config, 'destroy'), :status => 406
    end
  end

  def tree
    @tree = Brand.all.map do |b|
      fcs = FeedConfigDecorator.decorate_collection(b.feed_configs)
      Hash[b.name, Hash[fcs.map {|fc| [fc.feed_name, fc.config]}]]
    end

    render :json => @tree
  end

  private

  def actual_params
    @actual ||= params
    .require(:feed_config)
    .permit(:feed_name, :config)
    .tap{|p| fix_params_if_broken(p) unless @fixed}
  end

  def check_token
    if (params[:token] != 'dedamrazcetidonjetdarove') || (request.remote_ip != '127.0.0.1')
      render :text => 'not authorized', :status => 406
    end
  end

  # Sometimes the API sends arrays serialized as Javascript objects
  # in form of { "1": "val1", "2": "val2 }. This method fixes that.
  def fix_params_if_broken(params)
    fn = params.fetch(:feed_name)
    cfg = params.fetch(:config) { Hash.new }

    params[:config] = {} if params[:config] == ""

    if fn == 'facebook' && cfg[:pages]
      cfg[:pages] = cfg[:pages].map{|k,v| v}.reject{|el| el.nil?}

    elsif fn == 'meetup' && cfg[:groups]
      cfg[:groups] = cfg[:groups].map{|k,v| v}.reject{|el| el.nil?}

    elsif fn == 'disqus' && cfg[:forums]
      cfg[:forums] = cfg[:forums].map{|k,v| v}.reject{|el| el.nil?}
    end

    @fixed = true
  end
end
