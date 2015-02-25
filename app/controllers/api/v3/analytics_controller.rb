class Api::V3::AnalyticsController < Api::V3::BaseController
  
  def show
    source

    @timepoints = Histogram.stats_by_source_type(source_type, resolution)
      .where("source_fk" => @source_id)
      .limit(last)

    render :show
  rescue ArgumentError => e
    render :json => { message: e.message }.to_json, status: 406
  end

  def last
    params[:last] || default_last
  end

  def default_last
    case resolution
    when 'minute' then 60
    when 'hour' then 24
    when 'day' then 30
    when 'week' then 52
    when 'month' then 12
    end
  end
  
  def source
    if embed_id
      @source = Embed.find(embed_id)
      @source_id = @source.services.pluck(:id)
    elsif service_id
      @source = Service.find_by_id(service_id)
      @source_id = @source.id
    else
      @source_id = params[:source_id]
    end
  end

  def service_id; params[:service_id]; end
  def embed_id; params[:embed_id]; end
  def resolution; params[:resolution]; end
  def source_type; params[:source_type]; end 
end
