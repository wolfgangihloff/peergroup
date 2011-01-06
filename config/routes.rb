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

  resources :supervisions, :only => [:show, :index] do
    member do
      # I know it sucks, I don't yet have idea where to put this
      get :topics_votes_view
      get :topic_questions_view
      get :ideas_view
      get :ideas_feedback_view
    end

    resources :topics, :only => [:create, :show] do
      resources :votes, :only => :create, :controller => :topic_votes
    end
    resources :questions, :only => [:create, :show] do
      resource :answer, :only => [:create, :show]
    end
    resources :ideas, :only => [:create, :update, :show]
    resources :ideas_feedbacks, :only => [:create, :show]
    resources :solutions, :only => [:create, :update]
    resources :solutions_feedbacks, :only => :create
    resources :supervision_feedbacks, :only => :create
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

