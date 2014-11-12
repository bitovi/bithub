require 'sidekiq/web'

Bithub::Application.routes.draw do

  # Frontend
  root 'frontend#index'

  # Admin
  resources :admin, only: %i(index) do
    collection do
      get 'choose_brand', to: 'admin#choose_brand'

      resources :subscriptions, only: %i() do
        collection do
          get 'edit/plan', to: 'subscriptions#edit_plan'
          get 'edit/cc', to: 'subscriptions#edit_cc'
          post 'update', to: 'subscriptions#update'
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

  # Stripe
  mount Stripe::Engine => "/stripe"

  # SERVICE API Routes

  namespace :api, defaults: { format: 'json' } do

    namespace :v3 do
      resources :embeds, except: %i(new edit) do
        resources :entities, to: 'embed_entities', only: %i(index destroy) do
          put :approve, on: :member
          put :disaprove, on: :member
          get :approved, on: :collection
          get :waitlisted, on: :collection
        end

        resources :filters, except: %i(new edit)
        resources :services, except: %i(new edit)
      end

      resources :services, except: %i(new edit) do
        get :tree, on: :collection
      end

      resources :filters, except: %i(new edit)

      resources :brands,  except: %i(new edit) do
        collection do
          get 'current', to: 'brands#show'
          put 'current', to: 'brands#update'
          get 'current/payments', to: 'payments#index'
          delete 'current/identities/:id', to: 'brand_identities#destroy'
        end
      end

      resources :services, except: %i(new edit)
      resources :filters, except: %i(new edit)
      resources :tags, except: %i(new edit)
    end
  end

  # TODO; add auth
  mount Sidekiq::Web => '/sidekiq'

  get '/:page', controller: 'frontend', action: 'render_page'
  get '/', controller: 'frontend', action: 'index'
end
