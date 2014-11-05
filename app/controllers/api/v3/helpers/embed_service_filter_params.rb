module Api::V3::Helpers
  module EmbedServiceFilterParams
    
    def embed_id
      params.require(:embed_id)
    end
    
    def service_id
      params.require(:service_id)
    end
    
    def filter_id
      params.require(:filter_id)
    end

    def service_params
      params.require(:service).permit(:feed_name)
    end

    def service_filter_params
      service_params.merge({json_config: json_config})
    end
    
    def filter_params
      @json ||= ActionController::Parameters.new(JSON.parse_nil(request.body.read))
      @json.require(:filter).permit(:id, :is_conj, :classification)
    end

    def queries_params
      @json ||= ActionController::Parameters.new(JSON.parse_nil(request.body.read))
      @json.require(:filter).permit(natlang_queries: %i(is_negated attr op val)).require(:natlang_queries)
    end

    def service_json_config_params
      @json ||= ActionController::Parameters.new(JSON.parse_nil(request.body.read))
      @json.require(:service).require(:json_config).permit!
    end
  end
end
