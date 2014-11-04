require 'sidekiq/web'

Bithub::Application.routes.draw do

  # Frontend
  root "frontend#index"

  # Admin
  resources :admin, only: %i(index) do
    collection do
      get 'choose_brand', to: 'admin#choose_brand'
      resources :subscriptions, only: %i(create) do
        collection do
          get 'new/:plan', to: 'subscriptions#new'
        end
      end
    end
  end

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

  # Stripe
  mount Stripe::Engine => "/stripe"

  # SERVICE API Routes

  namespace :api, defaults: { format: 'json' } do

    namespace :v3 do
      resources :embeds, except: %i(new edit) do
        resources :entities, to: 'embed_entities', only: %i(index destroy) do
          get :approved, on: :collection
          get :waitlisted, on: :collection
        end

        resources :filters, except: %i(new edit)
      end

      resources :brands,  except: %i(new edit) do
        collection do
          get 'current', to: 'brands#show'
          put 'current', to: 'brands#update'
          delete 'current/identities/:id', to: 'brand_identities#destroy'
        end
      end

      resources :services, except: %i(new edit)
      resources :filters, except: %i(new edit)
      resources :tags, except: %i(new edit)

      resources :payments, only: %i(index)
    end

    namespace :v2 do
      resources :entities, only: %i(create update destroy)


      get 'services/tree', to: 'services#tree'

      resources :brands,  except: %i(new edit)
      get 'brands/current', to: 'brands#show'
      put 'brands/current', to: 'brands#update'

      get 'tags/tree', to: 'tags#tree'

      resources :accounts, except: %i(new edit)

      get '*path', to: redirect('/api/v2')
      root to: 'base#home'
    end
  end

  # TODO; add auth
  mount Sidekiq::Web => '/sidekiq'

  get '*path', :controller => 'frontend', :action => 'index'
end
