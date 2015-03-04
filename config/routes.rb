require 'sidekiq/web'

Bithub::Application.routes.draw do

  # Frontend
  root 'frontend#index'

  # Admin
  resources :admin, only: %i(index) do
    collection do
      get 'embed', to: 'admin#embed'
      get 'choose_brand', to: 'admin#choose_brand'

      resources :subscriptions, only: %i() do
        collection do
          get 'edit/plan', to: 'subscriptions#edit_plan'
          get 'edit/cc',   to: 'subscriptions#edit_cc'
          post 'update',   to: 'subscriptions#update'
        end
      end
    end
  end

  # Devise
  devise_for :accounts, path: '/',
    controllers: {
      sessions: 'auth/account_sessions',
      registrations: 'auth/account_registrations',
      omniauth_callbacks: 'auth/omniauth_callbacks'
    },
    path_names: {
      sign_in: 'login',
      sign_out: 'logout',
      registration: 'register/:plan',
      sign_up: '', # points to '/register'
      password: 'secret',
      confirmation: 'verification',
      # unlock: 'unblock',
    }

  as :account do
    get 'register', to: redirect('register/starter')

    # RESTify some of Devise methods
    post   'api/auth/login',    to: 'api/auth/account_sessions#create'
    delete 'api/auth/logout',   to: 'api/auth/account_sessions#destroy'
    post   'api/auth/register', to: 'api/auth/account_registrations#create'
  end

  # Stripe
  mount Stripe::Engine => "/stripe"

  # SERVICE API Routes
  namespace :api, defaults: { format: 'json' } do

    namespace :v3 do
      resources :embeds, except: %i(new edit) do

        resources :entities, to: 'embed_entities', only: %i(index show destroy) do
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

      resources :presets, to: 'embed_presets', except: %i(new edit)

      resources :services, except: %i(new edit) do
        get 'tree', on: :collection
        get 'suggestions/:feed_name', on: :collection, to: 'services#suggestions'
        get 'suggestions/:feed_name/:feed_type', on: :collection, to: 'services#suggestions'
      end

      resources :filters, except: %i(new edit)

      resources :brands,  except: %i(new edit) do
        collection do
          get 'current', to: 'brands#show'
          put 'current', to: 'brands#update'
          get 'current/payments', to: 'payments#index'
          get 'current/identities', to: 'brand_identities#index'
          get 'current/identities/:id', to: 'brand_identities#show'
          delete 'current/identities/:id', to: 'brand_identities#destroy'
        end
      end

      resources :accounts, only: %i() do
        collection do
          get 'current', to: 'accounts#current'
        end
      end

      get 'analytics/:source_type', to: 'analytics#show'

      resources :brand_identities, path: 'identities', only: %i(index show destroy)
      resources :services, except: %i(new edit update)
      resources :filters, except: %i(new edit)
      resources :tags, except: %i(new edit)
    end
  end

  Sidekiq::Web.use Rack::Auth::Basic do |username, password|
    username == ENV["SIDEKIQ_USERNAME"] && password == ENV["SIDEKIQ_PASSWORD"]
  end unless Rails.env.development?
  mount Sidekiq::Web => '/sidekiq'

  get '/:page', controller: 'frontend', action: 'render_page'
  get '/', controller: 'frontend', action: 'index'
end
