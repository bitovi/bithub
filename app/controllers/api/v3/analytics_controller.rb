class Api::V3::AnalyticsController < Api::V3::ApiController

  def show
    authorize!(:read, Histogram)
    source

    if @source
      @timepoints = Histogram.stats_by_source_type(source_type, resolution)
        .where(:source_id => @source.id)
        .limit(last)
      response = { source: @source, timepoints: @timepoints }
    elsif @sources
      response = @sources.map do |s|
        @timepoints = Histogram\
          .stats_by_source_type(source_type, resolution)
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
    if source_type == Service && owner_id
      @sources = Hub.find(owner_id).services
    elsif source_type == Service && source_id
      @source = Service.find(source_id)
    elsif source_type == Hub && source_id
      @source = Hub.find(source_id)
    else
      fail ArgumentError.new("Missing params.")
    end
  end
  
  private
  
  def resolution
    params['resolution'] || 'hour'
  end

  def source_type
    if params[:source_type] == 'hubs'
      Hub
    elsif params[:source_type] == 'services'
      Service
    end
  end

  def source_id
    params['source_id']
  end

  def owner_id
    params['owner_id']
  end
end
