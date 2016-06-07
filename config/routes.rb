require 'sidekiq/web'

Bithub::Application.routes.draw do
	namespace :api do
		as :user do
		    post	"/users"				=>	"users#create"
			get		"/users"				=>	"users#index"
		    
			post	"/session"				=>	"sessions#create"
		    get		"/session"				=>	"sessions#index"
		    delete	"/session"				=>	"sessions#destroy"
			
			get		"/organizations" 		=>	"organizations#index"
			get		"/organizations/:id"	=>	"organizations#show"
			put		"/organizations/:id"	=>	"organizations#update"
			
			post	"/hubs"					=>	"hubs#create"
			get		"/hubs"					=>	"hubs#index"
			get		"/hubs/:id"				=>	"hubs#show"
			put		"/hubs/:id"				=>	"hubs#update"
			delete	"/hubs/:id"				=>	"hubs#destroy"

			# get		"/credentials"			=> "credentials#index"
			# delete	"/credentials/:id"		=> "credentials#destroy"
		end
	end

  get '/admin', to: 'kickstart#admin'
  get '/hub', to: 'kickstart#hub'
  get '/new_admin', to: 'kickstart#new_admin'

  resources :subscriptions, only: %i(show) do
    collection do
      get 'current', to: 'subscriptions#current'
      get 'edit/cc',   to: 'subscriptions#edit_cc'
      post 'update',   to: 'subscriptions#update'
    end
  end

  # Devise
  devise_for :users,
    controllers: {
      sessions: 'auth/sessions',
      registrations: 'auth/registrations',
      confirmations: 'auth/confirmations',
      invitations: 'auth/invitations',
      omniauth_callbacks: 'auth/omniauth_callbacks'
    }

  as :user do
    get '/user', to: redirect('/users/edit')

    get '/register', to: redirect('/users/sign_up')
    get '/login', to: redirect('/users/sign_in')
    get '/logout', to: redirect('/users/sign_out')

    get '/users/login', to: redirect('/users/sign_in')
    get '/users/logout', to: redirect('/users/sign_out')
    get '/users/register', to: redirect('/users/sign_up')
  end

  # Stripe
  mount Stripe::Engine => "/stripe"

  # SERVICE API Routes
  namespace :api, defaults: { format: 'json' } do
    root :to => 'api#api_id'

    namespace :v4 do
      root :to => 'v4#api_id'

      resources :hubs, except: %i(new edit) do
        resources :bits, controller: 'moderations', only: %i(index show) do
          put :decide, on: :member
          get :stats, on: :collection
        end
      end
    end

    namespace :v3 do
      root :to => 'v3#api_id'

      resources :hubs, except: %i(new edit) do
        post :moderate, on: :member
        put :publish, on: :member
        put :unpublish, on: :member

        resources :bits, controller: 'moderations', only: %i(index show destroy) do
          put :approve, on: :member
          put :disapprove, on: :member
          put :block, on: :member
          put :pin, on: :member
          put :unpin, on: :member
          get :approved, on: :collection
          get :waitlisted, on: :collection
        end

        resources :filters, except: %i(new edit)
        resources :services, except: %i(new edit update)
      end

      resources :embeds, controller: 'hub_presets', except: %i(new edit)

      resources :services, except: %i(new edit) do
        get 'tree', on: :collection
        get 'suggestions/:feed_name', on: :collection, to: 'services#suggestions'
        get 'suggestions/:feed_name/:feed_type', on: :collection, to: 'services#suggestions'
      end

      resources :brands,  except: %i(new edit) do
        collection do
          get 'current/payments', to: 'payments#index'
          get 'current/identities/:provider', to: 'credentials#index'
          get 'current/identities', to: 'credentials#index'
          get 'current/identities/:id', to: 'credentials#show'
          delete 'current/identities/:id', to: 'credentials#destroy'
        end
      end

      namespace :current do
        resource :user do
          resources :organizations, controller: 'user_organizations'
          resources :invitations, controller: 'user_organizations'
        end

        resource :organization do
          put 'choose', on: :collection
          resources :users, controller: 'organization_users'
          resources :invitations, controller: 'organization_users', status: 'pending'
        end
      
        resource :brand do
          resources :identities, controller: 'credentials'
        end
      end

      resources :credentials, path: 'identities', only: %i(index show destroy)
      resources :services, except: %i(new edit update)
      resources :subscriptions, only: %i(show) do
        collection do
          get 'current', to: 'subscriptions#current'
        end
      end

      resources :filters, except: %i(new edit)
      resources :tags, except: %i(new edit)
      resources :interactions, only: %i(index show create)
      resources :monthly_billings, only: %i(index)
      
      get 'hubs_by_organization', to: 'user_organizations_hubs#index'
      get 'analytics', to: 'analytics#show'
      get 'interactions', to: 'interactions#index'
    end
  end

  Sidekiq::Web.use Rack::Auth::Basic do |username, password|
    username == ENV["SIDEKIQ_USERNAME"] && password == ENV["SIDEKIQ_PASSWORD"]
  end unless Rails.env.development?
  mount Sidekiq::Web => '/sidekiq'

  get '/:page', to: 'static_pages#render_page'
  root 'static_pages#index'


  match '*path', via: :all, to: 'application#render_404'
end
