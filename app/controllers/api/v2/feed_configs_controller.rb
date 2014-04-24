class Api::V2::FeedConfigsController < Api::V2::BaseController
  respond_to :json
  # before_filter :check_token, :only => :tree

  def index
    @configs = FeedConfig.all

    render :index
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

  private

  def check_token
    if (params[:token] != 'dedamrazcetidonjetdarove') || (request.remote_ip != '127.0.0.1')
      render :text => 'not authorized', :status => 406
    end
  end
end
