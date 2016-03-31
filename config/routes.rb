require 'sidekiq/web'

Bithub::Application.routes.draw do
	namespace :api do
		devise_for :accounts, controller: { sessions: "api/sessions" }
		as :account do
		    post	"/accounts"			=> "accounts#create"
			get		"/accounts"			=> "accounts#index"
		    
			post	"/session"			=> "sessions#create"
		    get		"/session"			=> "sessions#index"
		    delete	"/session"			=> "sessions#destroy"
			
			get		"/organizations" 	=> "organizations#index"
		end
	end

  get '/admin', to: 'kickstart#admin'
  get '/embed', to: 'kickstart#embed'
  get '/new_admin', to: 'kickstart#new_admin'

  resources :subscriptions, only: %i(show) do
    collection do
      get 'current', to: 'subscriptions#current'
      get 'edit/cc',   to: 'subscriptions#edit_cc'
      post 'update',   to: 'subscriptions#update'
    end
  end

  # Devise
  devise_for :accounts,
    controllers: {
      sessions: 'auth/sessions',
      registrations: 'auth/registrations',
      confirmations: 'auth/confirmations',
      invitations: 'auth/invitations',
      omniauth_callbacks: 'auth/omniauth_callbacks'
    }

  as :account do
    get '/account', to: redirect('/accounts/edit')

    get '/register', to: redirect('/accounts/sign_up')
    get '/login', to: redirect('/accounts/sign_in')
    get '/logout', to: redirect('/accounts/sign_out')

    get '/accounts/login', to: redirect('/accounts/sign_in')
    get '/accounts/logout', to: redirect('/accounts/sign_out')
    get '/accounts/register', to: redirect('/accounts/sign_up')
  end

  # Stripe
  mount Stripe::Engine => "/stripe"

  # SERVICE API Routes
  namespace :api, defaults: { format: 'json' } do
    root :to => 'api#api_id'

    namespace :v4 do
      root :to => 'v4#api_id'

      resources :embeds, except: %i(new edit) do
        resources :entities, controller: 'embed_entities', only: %i(index show) do
          put :decide, on: :member
          get :stats, on: :collection
        end
      end
    end

    namespace :v3 do
      root :to => 'v3#api_id'

      resources :embeds, except: %i(new edit) do
        post :moderate, on: :member
        put :publish, on: :member
        put :unpublish, on: :member

        resources :entities, controller: 'embed_entities', only: %i(index show destroy) do
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

      resources :presets, controller: 'embed_presets', except: %i(new edit)

      resources :services, except: %i(new edit) do
        get 'tree', on: :collection
        get 'suggestions/:feed_name', on: :collection, to: 'services#suggestions'
        get 'suggestions/:feed_name/:feed_type', on: :collection, to: 'services#suggestions'
      end

      resources :brands,  except: %i(new edit) do
        collection do
          get 'current/payments', to: 'payments#index'
          get 'current/identities/:provider', to: 'brand_identities#index'
          get 'current/identities', to: 'brand_identities#index'
          get 'current/identities/:id', to: 'brand_identities#show'
          delete 'current/identities/:id', to: 'brand_identities#destroy'
        end
      end

      namespace :current do
        resource :account do
          resources :organizations, controller: 'account_organizations'
          resources :invitations, controller: 'account_organizations'
        end

        resource :organization do
          put 'choose', on: :collection
          resources :accounts, controller: 'organization_accounts'
          resources :invitations, controller: 'organization_accounts', status: 'pending'
        end
      
        resource :brand do
          resources :identities, controller: 'brand_identities'
        end
      end

      resources :brand_identities, path: 'identities', only: %i(index show destroy)
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
      
      get 'embeds_by_organization', to: 'account_organizations_embeds#index'
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
