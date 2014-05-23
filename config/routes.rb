JoruriMaps::Application.routes.draw do

  #root :to => 'system/admin/portals#index'
  root :to => 'gis/public/fronts#index'

  match "index.html"                               => "gis/public/fronts#index"
  match "index.html.r"                             => "gis/public/fronts#index"

  match "ud/"                                      => "ud/public/portal#index"
  match "ud/index(.:format)"                       => "ud/public/portal#index"
  match "ud/index.html.r"                          => "ud/public/portal#index"

  match '_admin'                 => 'gis/admin/maps#index'
  match '_admin.:format'         => 'gis/admin/maps#index'


  ## Admin

  match '_admin/login.:format'   => 'sys/admin/account#login'
  match '_admin/login'           => 'sys/admin/account#login'
  match '_admin/logout.:format'  => 'sys/admin/account#logout'
  match '_admin/logout'          => 'sys/admin/account#logout'
  match '_admin/account.:format' => 'sys/admin/account#info'
  match '_admin/account'         => 'sys/admin/account#info'
  match "_admin/sso"             => "sys/admin/account#sso"
  match '_admin/air_login'       => 'sys/admin/air#old_login'
  match '_admin/air_sso'         => 'sys/admin/air#login'
  match '_admin/cms'             => 'sys/admin/front#index'
  match '_admin/sys'             => 'sys/admin/front#index'
  match '_admin/system'          => 'sys/admin/front#index'


  ## Talk
  match '*path.html.mp3'         => 'cms/public/talk#down_mp3'
  match '*path.html.m3u'         => 'cms/public/talk#down_m3u'
  match '*path.html.r.mp3'       => 'cms/public/talk#down_mp3'
  match '*path.html.r.m3u'       => 'cms/public/talk#down_m3u'

  ## Modules
  Dir::entries("#{Rails.root}/config/modules").each do |mod|
    next if mod =~ /^\.+$/
    file = "#{Rails.root}/config/modules/#{mod}/routes.rb"
    load(file) if FileTest.exist?(file)
  end

  ## Files
  match "misc/attach_file/*path"                         => "gis/public/files#attach_file", :format => false

  ## Exception
  match '403.:format' => 'exception#index'
  match '404.:format' => 'exception#index'
  match '500.:format' => 'exception#index'
  match '*path'       => 'exception#index'


  # The priority is based upon order of creation:
  # first created -> highest priority.

  # Sample of regular route:
  #   match 'products/:id' => 'catalog#view'
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  #   match 'products/:id/purchase' => 'catalog#purchase', :as => :purchase
  # This route can be invoked with purchase_url(:id => product.id)

  # Sample resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Sample resource route with options:
  #   resources :products do
  #     member do
  #       get 'short'
  #       post 'toggle'
  #     end
  #
  #     collection do
  #       get 'sold'
  #     end
  #   end

  # Sample resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Sample resource route with more complex sub-resources
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', :on => :collection
  #     end
  #   end

  # Sample resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end

  # You can have the root of your site routed with "root"
  # just remember to delete public/index.html.
  # root :to => 'welcome#index'

  # See how all your routes lay out with "rake routes"

  # This is a legacy wild controller route that's not recommended for RESTful applications.
  # Note: This route will make all actions in every controller accessible via GET requests.
  # match ':controller(/:action(/:id))(.:format)'
end
