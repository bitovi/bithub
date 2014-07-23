require 'sidekiq/web'

Bithub::Application.routes.draw do

  root "kickstart#frontend"
  get "/admin", :to => "kickstart#admin"

  # Devise

  devise_for :users,
    path: '/api',
    controllers: { omniauth_callbacks: "api/auth/omniauth_callbacks" }

  devise_for :accounts,
    path: '/',
    controllers: {
      sessions: 'api/auth/account_sessions',
      registrations: 'api/auth/account_registrations'
    },
    path_names: {
      sign_up: 'register',
      sign_in: 'login',
      sign_out: 'logout'
    }


  # Dynamic image resizer

  post '/uploads/*other' => "uploads#index"


  # SERVICE API Routes

  namespace :api, :defaults => { :format => 'json' } do

    # Auth

    namespace :auth do
      get    :session, :to => 'sessions#current'
      get    :logout, :to => 'sessions#destroy', :as => :destroy_user_session
      post   :link_identity, :to => 'identities#link'
      delete 'unlink_identity/:uid', :to => 'identities#unlink'
    end

    # API v2

    namespace :v2 do

      # Entities
      resources :entities, :except => [:new, :edit] do
        get :summary, :on => :collection
        get :pagination, :on => :collection

        get :activities, :to => 'entity_activities#index'

        post   :upvote, :to => 'entity_activities#create_upvote'
        delete :upvote, :to => 'entity_activities#destroy_upvote'

        post   :award, :to => 'entity_activities#create_award'
        delete :award, :to => 'entity_activities#destory_award'
      end

      # Tags
      resources :tags, :except => [:new, :edit] do
        collection do
          get :tree, :to => 'tags#tree'
        end
      end

      # Users
      resources :users, :except => [:new, :edit] do
        get 'activities', :to => 'user_activities#index'
        get 'achievements', :to => 'user_activities#achievements'
        #get 'entities', :to => 'user_activities#entities'

        member do
          put 'role', :to => 'users#add_role'
          delete 'role', :to => 'users#remove_role'
        end

        # collection do
        #   get 'twitter', :to => 'users#from_twitter'
        #   get 'github', :to => 'users#from_github'
        # end
      end

      # Rewards
      resources :rewards do
        member do
          post "", :to => 'rewards#update'
        end
      end

      # Achievements
      resources :achievements, :only => [:index, :show, :update, :destroy]

      # Countries
      resources :countries, :only => :index

      # Brands
      get 'brands/brand', :to => 'brands#show'
      put 'brands/brand', :to => 'brands#update'
      resources :brands, :only => [:index, :show, :update]

      # Brand identities
      resources :brand_identities, :only => [:index, :show]

      # Accounts
      resources :accounts do
        member do
          put 'password', :to => 'accounts#update_password'
        end
      end

      # Tags
      resources :tags

      # Achievements
      resources :achievements

      # Scoring rules
      resources :scoring_rules

      # Category determination rules
      #resources :category_determination_rules

      # Funnelsj
      resources :funnels

      # Feed config
      resources :feed_configs do
        collection do
          get 'tree', :to => 'feed_configs#tree'
        end
      end

      # Non-matched redirect to root
      get '*path', :to => redirect("/api/v2")

      # Homepage
      root :to => "base#home"
    end
  end

  # authenticate :account, lambda {|a| a.has_role? :admin } do
  #   mount Sidekiq::Web => '/sidekiq'
  # end
  mount Sidekiq::Web => '/sidekiq'

  get '*path', :controller => 'kickstart', :action => 'frontend'
end
