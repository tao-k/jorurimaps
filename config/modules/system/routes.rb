JoruriMaps::Application.routes.draw do
  mod = "system"
  scp = "admin"

  scope "_#{scp}" do
    namespace mod do
      scope :module => scp do
        ## admin
        resources "ldap_groups",
          :controller => "ldap_groups",
          :path => ":parent/ldap_groups"
        resources "ldap_temporaries",
          :controller => "ldap_temporaries",
          :path => "ldap_temporaries" do
            member do
              get :synchronize
              post :synchronize
              put :synchronize
              delete :synchronize
            end
          end
        resources :users do
          collection do
            get :csv, :csvget, :csvup, :csvset, :list
            post :csvup, :csvset
          end
          member do
            get :csvshow
          end
        end
        resources :groups,
          :path => ":parent/groups" do
            collection do
              get :list
            end
          end
        resources :users_groups,
          :path => ":parent/users_groups" do
            collection do
              get :list
            end
          end
        resources "roles" do
          collection do
            get :user_fields, :getajax
          end
        end
        resources "priv_names"
        resources "role_names"
        resources "role_name_privs" do
          collection do
            get :getajax
          end
        end
        resources :custom_groups do
          collection do
            get :create_all_group, :synchro_all_group, :user_add_sort_no
            put :sort_update
            post :get_users
          end
        end
        resources :group_changes do
          collection do
            get :reflect, :csv_up
            post :csv_up
          end
        end

        resources :group_change_dates
        resources :group_change_pickups
        resources :group_updates do
          collection do
            get :csv
            post :csvup
          end
        end
        resources :prefs
        resources :zones
        resources :counties
        resources :cities
        resources :options
        resources :group_nexts
        resources :user_temporaries
        resources :group_temporaries
        resources :users_group_temporaries
        resources :group_history_temporaries
        resources :users_group_history_temporaries
        resources :fronts
        resources :siteinfo

        resources :short_messages
        resources :related_links
        resources :link_banners
        resources :social_updates do
          collection do
            get :get_info
          end
          resources :attach_files, :controller => 'social_updates/attach_files'
        end
      end
    end
  end
  ##API
  match 'api/checker'         => 'system/admin/api#checker'
  match 'api/checker_login'   => 'system/admin/api#checker_login'
  match 'api/air_sso'         => 'system/admin/api#sso_login'

  match ':controller(/:action(/:id))(.:format)'
end
