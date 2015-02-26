class Api::V3::AnalyticsController < Api::V3::BaseController
  
  def show
    source

    if @source
      @timepoints = Histogram.stats_by_source_type(source_type, resolution)
        .where(:source_id => @source.id)
        .limit(last)

      response = {
        source: @source,
        timepoints: @timepoints
      }
    elsif @sources
      response = @sources.map do |s|
        @timepoints = Histogram.stats_by_source_type(source_type, resolution)
          .where(:source_id => s.id)
          .limit(last)

        { source: s, timepoints: @timepoints }
      end
    end

    render :json => response
  rescue ArgumentError => e
    render :json => { message: e.message }.to_json, status: 406
  end

  def last
    params[:last] || default_last
  end

  def default_last
    case resolution
    when 'minute' then 30
    when 'hour' then 24
    when 'day' then 30
    when 'week' then 52
    when 'month' then 12
    end
  end
  
  def source
    if source_type == 'embeds' && embed_id
      @source = Embed.find(embed_id)
    elsif source_type == 'services' && service_id
      @source = Service.find(service_id)
    elsif source_type == 'services' && embed_id
      @sources = Embed.find(embed_id).services
    else
      fail ArgumentError.new('wrong combination of params')
    end
  end

  def service_id; params[:service_id]; end
  def embed_id; params[:embed_id]; end
  def resolution; params[:resolution]; end
  def source_type; params[:source_type]; end 
end
