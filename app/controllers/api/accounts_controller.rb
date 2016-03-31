class Api::AccountsController < Api::BaseController
	include Api::Helpers::Filter
	
	before_action :ensure_current_account, only: [ :index ]
	
	def create
		account = Account.new params_to_account_arguments params
		ActiveRecord::Base.transaction do
	        unless account.save
		        return render_error_message account.errors, account.errors, :unprocessable_entity
	        end
		end
		
		org_builder = Organizations::OrganizationBuilder.new account, params
		begin
			ActiveRecord::Base.transaction do
				org_builder.build.save!
			end
		rescue Organizations::OrganizationBuilder::BuildingError => e
			return render_error_message e, e, :unprocessable_entity
		rescue ActiveRecord::RecordInvalid => e
			return render_error_message e, e, :unprocessable_entity
		end

		sign_in :account, account
		return render json: account, status: :created
	rescue KeyError => e
		render_error_message e, e, :bad_request
    end
		
	def index
		return render json: filter(Account, sanitize(params)), status: :ok
	end
	
	private
	
	def params_to_account_arguments params
		{ 
			email: params.fetch(:email), 
			password: params.fetch(:password),
			confirmed_at: DateTime.now,
			confirmation_sent_at: DateTime.now
		}
	end
end
