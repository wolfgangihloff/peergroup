ActionController::Routing::Routes.draw do |map|
  map.resources :rules


  map.resources(:chat_rooms, :member =>
    {:select_leader => :post, :select_problem_owner => :post, :select_current_rule => :post}
  ) do |chat_rooms|
    chat_rooms.resources :chat_updates
    chat_rooms.resources :chat_users
  end

  map.resources :users, :member => { :following => :get, :followers => :get }
  map.resources :sessions, :only => [:new, :create, :destroy]
  map.resources :microposts, :only => [:create, :destroy]
  map.resources  :relationships, :only => [:create, :destroy]

  map.all_groups 'all_groups',:controller=>"groups",:action=>"all_groups"
  map.join_group 'join_group/:id',:controller=>"groups",:action=>"join_group"
  map.delete_group 'delete_group/:id',:controller=>"groups",:action=>"destroy"
  map.cancle_group 'cancle_group',:controller=>"groups",:action=>"cancle"
  map.group_edit '/edit', :controller => 'groups',:action => 'edit'

  map.resources :groups do |groups|
    groups.resources :memberships
    groups.resources :rules
  end

  map.signin  '/signin',  :controller => 'sessions', :action => 'new'
  map.signout '/signout', :controller => 'sessions', :action => 'destroy'
  map.contact '/contact', :controller => 'pages', :action => 'contact'
  map.about   '/about',   :controller => 'pages', :action => 'about'
  map.help    '/help',    :controller => 'pages', :action => 'help'
  map.signup '/signup',   :controller => 'users', :action => 'new'
  

  # The priority is based upon order of creation: first created -> highest priority.

  # Sample of regular route:
  #   map.connect 'products/:id', :controller => 'catalog', :action => 'view'
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  #   map.purchase 'products/:id/purchase', :controller => 'catalog', :action => 'purchase'
  # This route can be invoked with purchase_url(:id => product.id)

  # Sample resource route (maps HTTP verbs to controller actions automatically):
  #   map.resources :products

  # Sample resource route with options:
  #   map.resources :products, :member => { :short => :get, :toggle => :post }, :collection => { :sold => :get }

  # Sample resource route with sub-resources:
  #   map.resources :products, :has_many => [ :comments, :sales ], :has_one => :seller
  
  # Sample resource route with more complex sub-resources
  #   map.resources :products do |products|
  #     products.resources :comments
  #     products.resources :sales, :collection => { :recent => :get }
  #   end

  

  # Sample resource route within a namespace:
  #   map.namespace :admin do |admin|
  #     # Directs /admin/products/* to Admin::ProductsController (app/controllers/admin/products_controller.rb)
  #     admin.resources :products
  #   end

  # You can have the root of your site routed with map.root -- just remember to delete public/index.html.
  map.root :controller => "pages", :action => 'home'

  # See how all your routes lay out with "rake routes"

  # Install the default routes as the lowest priority.
  # Note: These default routes make all actions in every controller accessible via GET requests. You should
  # consider removing or commenting them out if you're using named routes and resources.
  map.connect ':controller/:action/:id'
  map.connect ':controller/:action/:id.:format'
end
