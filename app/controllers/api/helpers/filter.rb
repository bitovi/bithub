module Api::Helpers
	module Filter
		def filter model, params
			return model.all unless includes_query params
			
			where = where(model, params)
			includes = includes(where, params)
			ordered = order(includes, params)
			offset = offset(ordered, params)
			limited = limit(offset, params)
			as_json(limited, params)
		end
		
		def includes_query params
			%w[where includes order offset limit includes].any? {|param|
				params.include? param
			}
		end

		def where model, params
			return model.where(params[:where]) if params[:where]
			model
		end

		def includes model, params
			return model.includes(params[:includes]) if params[:includes]
			model
		end

		def order model, params
			return model.order(params[:order]) if params[:order]
			model
		end

		def offset model, params
			return model.offset(params[:offset]) if params[:offset]
			model
		end

		def limit model, params
			return model.limit(params[:limit]) if params[:limit]
			model
		end

		def as_json model, params
			return model.as_json(include: params[:includes]) if params[:includes]
			model
		end
	end
end
