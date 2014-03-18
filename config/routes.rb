Bithub::Application.routes.draw do

  devise_for :users,
    controllers: { omniauth_callbacks: "api/auth/omniauth_callbacks" }

  as :user do
    post   '/api/auth/link_identity', :to => 'api/auth/identities#link'
    delete '/api/auth/unlink_identity/:uid', :to => 'api/auth/identities#unlink'
    get    '/api/auth/logout', :to => 'devise/sessions#destroy', :as => :destroy_user_session
  end

  # Dynamic image resizer
  #
  match '/uploads/*other' => "uploads#index"

  # SERVICE API Routes
  #
  namespace :api, :defaults => { :format => 'json' } do
    match '/auth/session' => 'auth/session_info#current_session'

    # API v2
    #
    namespace :v2 do

      # Entities

      # Users

      # Rewards

      # Achievements

      # Countries
      resources :countries, :only => :index

      # Brands

      # Accounts

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
        resource 'anteup', :only => :create, :to => 'event_activities#create_anteup'
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

  match 'api/v:number/*path', :to => redirect {|params, req| "/api/v1/#{params[:path]}?#{req.query_string}"}
  match 'api/*path', :to => redirect {|params, req| "/api/v1/#{params[:path]}?#{req.query_string}"}
end
