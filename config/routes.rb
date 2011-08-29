Peergroupsupervision::Application.routes.draw do
  filter :locale

  resources :users, :except => [:index] do
    member do
      get :following
      get :followers
    end
  end
  resources :sessions, :only => [:new, :create, :destroy]
  resource :relationships, :only => [:create, :destroy]

  resources :topics, :only => [] do
    resources :votes, :only => :create, :controller => :topic_votes
  end
  resources :questions, :only => :show do
    resources :answers, :only => :create
  end
  resources :ideas, :only => [:update, :show]
  resources :solutions, :only => [:update, :show]
  resources :supervision_feedbacks, :only => :show

  resources :supervisions, :only => [:show, :index, :update] do
    get :statusbar, :on => :member
    get :cancel, :on => :member
    resources :topics, :only => [:create, :index, :show]
    resources :questions, :only => :create
    resources :ideas, :only => :create
    resource :ideas_feedback, :only => [:create, :show]
    resources :solutions, :only => :create
    resource :solutions_feedback, :only => [:create, :show]
    resources :supervision_feedbacks, :only => :create
    resources :votes, :only => :create

    resource :membership, :controller => :supervision_memberships, :only => [:new, :create, :destroy]
  end

  resources :groups, :only => [:index, :show] do
    resources :supervisions, :only => [:new, :create]
    resource :membership
    resource :chat_room, :only => :show
    resource :invitation, :only => [:update, :destroy]
    resources :requests, :only => [:create]
  end

  resources :chat_room, :only => [] do
    resources :chat_messages, :only => :create
  end

  namespace :founder do
    resources :groups, :only => [:new, :create, :edit, :update] do
      resources :invitations, :only => [:new, :create]
      resources :requests, :only => [:update, :destroy]
      resources :memberships, :only => [:destroy]
    end
  end

  namespace :node do
    resources :supervisions, :only => [] do
      resources :members, :only => [:destroy]
    end
  end

  get '/signin' => 'sessions#new', :as => 'signin'
  delete '/signout' =>'sessions#destroy', :as => 'signout'
  get '/contact' => 'pages#contact', :as => 'contact'
  get '/about' => 'pages#about', :as => 'about'
  get '/help' => 'pages#help', :as => 'help'
  get '/signup' =>'users#new', :as => 'signup'

  root :to => 'pages#home'
end
