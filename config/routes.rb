Peergroupsupervision::Application.routes.draw do
  resources :rules

  resources :chat_rooms do

    member do
      %w{leader problem_owner}.each {|role| post :"select_#{role}"}
    end

    resources :chat_updates
    resources :chat_users
    resources :chat_rules
  end

  resources :users, :member => { :following => :get, :followers => :get }
  resources :sessions, :only => [:new, :create, :destroy]
  resources :relationships, :only => [:create, :destroy]
  resources :supervisions, :only => [:new, :create, :show]
  resources :supervision_votes
  resources :topics, :only => [:new, :index, :create]
  resources :topic_votes
  resources :topic_questions
  resources :topic_answers
  resources :ideas
  resources :ideas_feedbacks
  resources :solutions
  resources :solutions_feedbacks

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

  match ':controller(/:action(/:id(.:format)))'
end

