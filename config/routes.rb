Peergroupsupervision::Application.routes.draw do
  filter :locale

  resources :rules

  resources :users do
    member do
      get :following
      get :followers
    end
  end
  resources :sessions, :only => [:new, :create, :destroy]
  resource :relationships, :only => [:create, :destroy]

  resources :topics, :only => :show do
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
    resources :topics, :only => [:create, :index]
    resources :questions, :only => :create
    resources :ideas, :only => :create
    resource :ideas_feedback, :only => [:create, :show]
    resources :solutions, :only => :create
    resource :solutions_feedback, :only => [:create, :show]
    resources :supervision_feedbacks, :only => :create
    resources :votes, :only => :create

    resource :membership, :controller => :supervision_memberships, :only => [:new, :create, :destroy]
  end

  resources :groups do
    get :all, :on => :collection
    resources :supervisions, :only => [:new, :create]
    resources :rules
    resource :membership do
      put :accept, :on => :member
      delete :reject, :on => :member
    end
    resource :chat_room, :only => :show
    resources :invitations, :only => [:index, :new, :create]
  end

  resources :chat_room, :only => [] do
    resources :chat_messages, :only => :create
  end

  match '/signin' => 'sessions#new', :as => 'signin'
  match '/signout' =>'sessions#destroy', :as => 'signout'
  match '/contact' => 'pages#contact', :as => 'contact'
  match '/about' => 'pages#about', :as => 'about'
  match '/help' => 'pages#help', :as => 'help'
  match '/signup' =>'users#new', :as => 'signup'

  root :to => 'pages#home'
end
