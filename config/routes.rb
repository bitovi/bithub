require 'sidekiq/web'

Bithub::Application.routes.draw do

  root 'kickstart#frontend'
  get '/admin', to: 'kickstart#admin'

  devise_for :users, path: '/api',
    controllers: {
      omniauth_callbacks: 'api/auth/omniauth_callbacks'
    }

  devise_for :accounts, path: '/',
    controllers: {
      sessions: 'api/auth/account_sessions',
      registrations: 'api/auth/account_registrations'
    },
    path_names: {
      sign_up: 'register',
      sign_in: 'login',
      sign_out: 'logout'
    }

  post '/uploads/*other' => 'uploads#index'
  get '/uploads/*other' => 'uploads#index'

  namespace :api, defaults: { format: 'json' } do
    namespace :auth do
      get :session, to: 'sessions#current'
      get :logout, to: 'sessions#destroy', as: :destroy_user_session
      post :link_identity, to: 'identities#link'
      delete 'unlink_identity/:uid', to: 'identities#unlink'
    end

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

      resources :brands, only: %i(show update)
      get 'brands/current/services', to: 'brand#services'
      get 'brands/current/embeds', to: 'brand#embeds'
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

  get '*path', controller: 'kickstart', action: 'frontend'
end
