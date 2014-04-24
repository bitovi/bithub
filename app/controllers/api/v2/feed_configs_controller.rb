class Api::V2::FeedConfigsController < Api::V2::BaseController
  respond_to :json
  # before_filter :check_token, :only => :tree

  rescue_from ActiveRecord::RecordNotFound, with: :show_404
  rescue_from ActiveRecord::RecordInvalid, with: :show_406

  def index
    @configs = FeedConfig.all

    render :index
  end

  def show
    @config = FeedConfig.find(params[:id])
    render :show
  end

  def create
    @config = FeedConfig.new(config_params)

    if @config.save
      render :show
    else
      render :json => msg_hash(@config, 'create'), :status => 406
    end
  end

  def update
    @config = FeedConfig.where(brand_name: current_account.brand.name, id: params[:id]).first
    if @config && @config.update_attributes(config_params)
      render :show
    else
      render :json => msg_hash(@config, 'update'), :status => 406
    end
  end

  def destroy
    @config = FeedConfig.find(params[:id])
    if @config.destroy
      render :json => msg_hash(@config, 'destroy', 'success')
    else
      render :json => msg_hash(@config, 'destroy'), :status => 406
    end
  end

  def tree
    grouped_configs = FeedConfig.all
    .each do |fc|
      fc.config = fc.builder.config
    end.map do |fc|
      fc.attributes
    end.group_by do |el|
      el['brand_name']
    end


    @configs = Hash[grouped_configs.keys.zip(
      grouped_configs.values.map do |bc|
        bc.each do |fc|
          fc.delete('brand_name')
        end.map do |fc|
          Hash[fc['feed_name'], fc['config']]
        end.reduce({}) do |acc, el|
          acc.merge(el)
        end
      end
    )]

    render :json => @configs
  end

  # def self.config_definitions
  #   {
  #     github:     [:token, :repos, :orgs],
  #     meetup:     [:token, :terms, :groups],
  #     facebook:   [:token, :pages => [:id, :token]],
  #     twitter:    [:token, :token_secret, :terms],
  #     disqus:     [:token, :forums],
  #     foursquare: [:token, :venues]
  #   }
  # end

  private

  def config_params
    params
    .require(:feed_config)
    .permit(:brand_name, :feed_name, :config)
    .tap {|wl| wl[:config] = params[:feed_config][:config]}
  end

  def check_token
    if (params[:token] != 'dedamrazcetidonjetdarove') || (request.remote_ip != '127.0.0.1')
      render :text => 'not authorized', :status => 406
    end
  end
end
