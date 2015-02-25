class Api::V3::AnalyticsController < Api::V3::BaseController
  
  def by_type_and_id
    render :json => Histogram.stats_by_source_type_and_source_id(source_type, source_id, resolution)
  rescue ArgumentError => e
    render :json => { message: e.message }.to_json, status: 406
  end

  def by_type
    render :json => Histogram.stats_by_source_type(source_type, resolution)
  rescue ArgumentError => e
    render :json => { message: e.message }.to_json, status: 406
  end

  def resolution
    params[:resolution]
  end

  def source_type
    params[:source_type]
  end

  def source_id
    params[:source_id].to_i
  end
end
