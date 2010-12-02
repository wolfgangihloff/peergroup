Peergroupsupervision::Application.routes.draw do
  resources :rules

  resources :chat_rooms do

    member do
      post :select_leader
      post :select_problem_owner
    end

    resources :chat_updates
    resources :chat_users
    resources :chat_rules
  end

  resources :users do
    get :following
    get :followers
  end
  resources :sessions, :only => [:new, :create, :destroy]
  resource :relationships, :only => [:create, :destroy]

  resources :supervisions, :only => [:new, :create, :show] do
    resources :ideas
    resources :ideas_feedbacks
    resources :solutions
    resources :solutions_feedbacks
    resources :topic_answers
    resources :topic_questions
    resources :topic_votes
    resources :topics, :only => [:new, :index, :create]
    resources :votes
  end

  resources :groups do
    resources :memberships
    resources :rules
  end

  match '/signin' => 'sessions#new', :as => 'signin'
  match '/signout' =>'sessions#destroy', :as => 'signout'
  match '/contact' => 'pages#contact', :as => 'contact'
  match '/about' => 'pages#about', :as => 'about'
  match '/help' => 'pages#help', :as => 'help'
  match '/signup' =>'users#new', :as => 'signup'

  root :to => 'pages#home'
end

