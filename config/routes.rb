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
      resources :entities, except: [:new, :edit] do
        get :summary, on: :collection
        get :pagination, on: :collection
        get :activities, to: 'entity_activities#index'
        post :upvote, to: 'entity_activities#create_upvote'
        post :award, to: 'entity_activities#create_award'
        delete :upvote, to: 'entity_activities#destroy_upvote'
        delete :award, to: 'entity_activities#destory_award'
      end

      resources :tags, except: [:new, :edit] do
        collection do
          get :tree, to: 'tags#tree'
        end
      end

      resources :users, except: [:new, :edit] do
        get 'activities', to: 'user_activities#index'
        get 'achievements', to: 'user_activities#achievements'

        member do
          put 'role', to: 'users#add_role'
          delete 'role', to: 'users#remove_role'
        end
      end

      resources :rewards do
        member do
          post '', to: 'rewards#update'
        end
      end

      resources :accounts do
        member do
          put 'password', to: 'accounts#update_password'
        end
      end

      resources :services do
        collection do
          get 'tree', to: 'feed_configs#tree'
        end
      end

      get 'brands/brand', to: 'brands#show'
      put 'brands/brand', to: 'brands#update'
      resources :brands, only: [:index, :show, :update]
      resources :brand_identities, only: [:index, :show, :destroy]
      resources :tags
      resources :achievements
      resources :scoring_rules
      resources :funnels
      resources :achievements, only: [:index, :show, :update, :destroy]
      resources :countries, only: :index

      get '*path', to: redirect('/api/v2')
      root to: 'base#home'
    end
  end

  # TODO add auth
  mount Sidekiq::Web => '/sidekiq'

  get '*path', controller: 'kickstart', action: 'frontend'
end
