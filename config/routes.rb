ActionController::Routing::Routes.draw do |map|
  resources :rules

  resources(:chat_rooms, :member =>
    {:select_leader => :post, :select_problem_owner => :post, :select_current_rule => :post}
  ) do
    resources :chat_updates
    resources :chat_users
    resources :chat_rules
  end

  resources :users, :member => { :following => :get, :followers => :get }
  resources :sessions, :only => [:new, :create, :destroy]
  resources :microposts, :only => [:create, :destroy]
  resources  :relationships, :only => [:create, :destroy]

  resources :groups do
    resources :memberships
    resources :rules
  end

  match '/signin' => 'sessions#new', :as => 'signin'
  match '/signup' =>'sessions#destroy', :as => 'signout'
  match '/contact' => 'pages#contact', :as => 'contact'
  match '/about' => 'pages#about', :as => 'about'
  match '/help' => 'pages#help', :as => 'help'
  match '/signup' =>'users#new', :as => 'signup'

  root :to => 'pages#home'

  match ':controller(/:action(/:id(.:format)))'
end
