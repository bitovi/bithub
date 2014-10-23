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

    namespace :v2 do
      resources :entities, except: %i(new edit) do
        get :summary, on: :collection
        get :pagination, on: :collection
        get :activities, to: 'entity_activities#index'
        post :upvote, to: 'entity_activities#create_upvote'
        post :award, to: 'entity_activities#create_award'
        delete :upvote, to: 'entity_activities#destroy_upvote'
        delete :award, to: 'entity_activities#destory_award'
      end

      resources :users, except: %i(new edit) do
        get 'activities', to: 'user_activities#index'
        get 'achievements', to: 'user_activities#achievements'

        member do
          put 'role', to: 'users#add_role'
          delete 'role', to: 'users#remove_role'
        end
      end

      # resources :brands, only: %i(show update)
      get 'brands/current/services', to: 'brands#services'
      get 'brands/current/embeds', to: 'brands#embeds'
      get 'brands/current', to: 'brands#show'
      put 'brands/current', to: 'brands#update'

      resources :services, except: %i(new edit)
      get 'services/tree', to: 'services#tree'

      resources :tags, except: %i(new edit)
      get 'tags/tree', to: 'tags#tree'

      resources :accounts, except: %i(new edit)
      resources :brand_identities, only: %i(index show destroy)
      resources :tags, except: %i(new edit)
      resources :achievements, except: %i(new edit)
      resources :rewards, except: %i(new edit)
      resources :scoring_rules, except: %i(new edit)
      resources :funnels, except: %i(new edit)
      resources :achievements, except: %i(new create edit)
      resources :countries, only: :index

      get '*path', to: redirect('/api/v2')
      root to: 'base#home'
    end
  end

  # TODO; add auth
  mount Sidekiq::Web => '/sidekiq'

  get '*path', :controller => 'frontend', :action => 'index'
end
