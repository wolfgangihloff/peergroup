Peergroupsupervision::Application.routes.draw do
  resources :rules

  resources :users do
    member do
      get :following
      get :followers
    end
    resources :groups
  end
  resources :sessions, :only => [:new, :create, :destroy]
  resource :relationships, :only => [:create, :destroy]

  resources :supervisions, :only => [:show, :index, :update] do
    resources :topics, :only => [:create, :show, :index] do
      resources :votes, :only => :create, :controller => :topic_votes
    end
    resources :questions, :only => [:create, :show] do
      resource :answer, :only => :create
    end
    resources :ideas, :only => [:create, :update, :show]
    resource :ideas_feedback, :only => [:create, :show]
    resources :solutions, :only => [:create, :update, :show]
    resource :solutions_feedback, :only => [:create, :show]
    resources :supervision_feedbacks, :only => [:create, :show]
    resources :votes, :only => :create
  end

  resources :groups do
    resources :supervisions, :only => [:new, :create]
    resources :memberships
    resources :rules
    resource :chat_room, :only => :show do
      resources :chat_messages, :only => :create
    end
  end

  match '/signin' => 'sessions#new', :as => 'signin'
  match '/signout' =>'sessions#destroy', :as => 'signout'
  match '/contact' => 'pages#contact', :as => 'contact'
  match '/about' => 'pages#about', :as => 'about'
  match '/help' => 'pages#help', :as => 'help'
  match '/signup' =>'users#new', :as => 'signup'

  root :to => 'pages#home'
end

