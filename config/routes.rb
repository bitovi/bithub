require 'sidekiq/web'

Bithub::Application.routes.draw do

  root "frontend#index"

  get "/admin", :to => "admin#index"
  get "/admin/choose_brand", :to => "admin#choose_brand"

  # Devise
  devise_for :accounts, path: '/',
    controllers: {
    sessions: 'api/auth/account_sessions',
    registrations: 'api/auth/account_registrations',
    omniauth_callbacks: 'api/auth/omniauth_callbacks'
  },
  path_names: {
    sign_in: 'login',
    sign_out: 'logout',
    registration: 'register',
    sign_up: '', # points to '/register'
    password: 'secret',
    confirmation: 'verification',
    # unlock: 'unblock',
  }

  # Dynamic image resizer

  post '/uploads/*other' => "uploads#index"
  get '/uploads/*other' => "uploads#index"

  # SERVICE API Routes

  namespace :api, defaults: { format: 'json' } do

    namespace :v3 do
      resources :embeds, except: %i(new edit) do
        resources :entities, to: 'embed_entities', only: %i(index destroy) do
          get :approved, on: :collection
          get :waitlisted, on: :collection
        end
      end
      
      resources :brands,  except: %i(new edit) do
        get 'current', on: :collection, to: 'brands#show'
        put 'current', on: :collection, to: 'brands#update'
      end
    end

    namespace :v2 do
      resources :entities, only: %i(create update destroy)

      resources :filters, except: %i(new edit)

      resources :services, except: %i(new edit)
      get 'services/tree', to: 'services#tree'

      resources :brands,  except: %i(new edit)
      get 'brands/current', to: 'brands#show'
      put 'brands/current', to: 'brands#update'

      resources :tags, except: %i(new edit)
      get 'tags/tree', to: 'tags#tree'

      resources :accounts, except: %i(new edit)
      resources :brand_identities, only: %i(index show destroy)

      get '*path', to: redirect('/api/v2')
      root to: 'base#home'
    end
  end

  # TODO; add auth
  mount Sidekiq::Web => '/sidekiq'

  get '*path', :controller => 'frontend', :action => 'index'
end
