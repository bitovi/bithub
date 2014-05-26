Bithub::Application.routes.draw do

  match "/api/login_and_oauth", :to => 'api/auth/sign_in_oauth#login_and_redirect_to_oauth'

  # Devise
  #
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
  #
  match '/uploads/*other' => "uploads#index"


  # SERVICE API Routes
  #
  namespace :api, :defaults => { :format => 'json' } do

    # Auth
    #
    namespace :auth do
      get    :session, :to => 'sessions#current'
      get    :logout, :to => 'sessions#destroy', :as => :destroy_user_session
      post   :link_identity, :to => 'identities#link'
      delete 'unlink_identity/:uid', :to => 'identities#unlink'
    end

    # API v2
    #
    namespace :v2 do

      # Entities
      resources :entities, :except => [:new, :edit] do
        get :summary, :on => :collection
        get :pagination, :on => :collection

        get :activities, :to => 'event_activities#index'

        post   :upvote, :to => 'event_activities#create_upvote'
        delete :upvote, :to => 'event_activities#destroy_upvote'

        post   :award, :to => 'event_activities#create_award'
        delete :award, :to => 'event_activities#destory_award'
      end

      # Users
      resources :users, :except => [:new, :edit] do
        get 'activities', :to => 'user_activities#index'
        get 'achievements', :to => 'user_activities#achievements'
        #get 'entities', :to => 'user_activities#entities'

        member do
          put 'addrole', :to => 'users#add_role'
          put 'removerole', :to => 'users#remove_role'
        end

        collection do
          get 'twitter', :to => 'users#from_twitter'
          get 'github', :to => 'users#from_github'
        end
      end

      # Rewards
      resources :rewards do
        member do
          post "", :to => 'rewards#update'
        end
      end

      # Countries
      resources :countries, :only => :index

      # Brands
      resources :brands, :only => [:index, :show, :update]

      # Brand identities
      resources :brand_identities, :only => [:index, :show]

      # Accounts
      resources :accounts do
        member do
          put 'password', :to => 'accounts#update_password'
        end
      end

      # Scoring rules
      resources :scoring_rules

      # Scoring rules
      resources :category_determination_rules

      # Funnelsj
      get 'funnels', :to => 'funnels#index'
      get 'funnels/:name', :to => 'funnels#show'
      post 'funnels', :to => 'funnels#create'
      put 'funnels/:name', :to => 'funnels#update'
      delete 'funnels/:name', :to => 'funnels#destroy'

      # Feed config
      resources :feed_configs do
        collection do
          get 'tree', :to => 'feed_configs#tree'
        end
      end

      # Non-matched redirect to root
      match '*path', :to => redirect("/api/v2")

      # Homepage
      root :to => "base#home"
    end

    # API v1
    #
    namespace :v1, :defaults => { :format => 'json', :handler => 'jpbuilder' } do

      resources :events, :except => [:new, :edit] do
        resources 'activities', :only => :index, :to => 'event_activities#index'
        resources 'upvote', :only => :create, :to => 'event_activities#create_upvote'
        resource 'award', :only => :create, :to => 'event_activities#create_award'
        get :summary, :on => :collection
        get :pagination, :on => :collection
        delete :upvote, :to => 'event_activities#destroy_upvote'
      end

      resources :users, :except => [:new] do
        resources 'activities', :only => :index, :to => 'user_activities#index'
        resources 'accomplishments', :only => :index, :to => 'user_activities#accomplishments'
        resources 'events', :only => :index, :to => 'user_events#index'
        member do
          put 'addrole', :to => 'users#add_role'
          put 'removerole', :to => 'users#remove_role'
        end
        collection do
          get 'twitter', :to => 'users#from_twitter'
          get 'github', :to => 'users#from_github'
        end
      end

      resource :pagination, :only => [:index]

      resources :tags, :except => [:new, :edit] do
        collection do
          get :feeds, :to => 'tags#index'
          get :categories, :to => 'tags#index'
          get :projects, :to => 'tags#index'
        end
      end

      resources :rewards
      resources :achievements
      resources :countries, :only => :index

      root :to => "base#home"
    end
  end

  # Redirect to v1 endpoints
  #
  # match 'api/v:number/*path', :to => redirect {|params, req| "/api/v1/#{params[:path]}?#{req.query_string}"}
  # match 'api/*path', :to => redirect {|params, req| "/api/v1/#{params[:path]}?#{req.query_string}"}
end
