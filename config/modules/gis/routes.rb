JoruriMaps::Application.routes.draw do
  mod = "gis"
  scp = "admin"
  public_scp = "public"


  ## admin
  scope "_#{scp}" do
    namespace mod do
      scope :module => scp do
        ## admin
        resources "fronts",
          :controller => "fronts",
          :path => "fronts"
        resources "demos",
          :controller => "demos",
          :path => "demos" do
            collection do
              get :view, :get_nearby_offices, :map, :bbox, :get_bbox, :layer, :map_simple, :mapjs, :draw, :feature_edit, :measure, :base_layer, :import
              post :export, :import
            end
            member do
              get :feature, :download_kml, :data, :extjs, :slider, :dual, :dual_js, :folder_remark
              post :legend
            end
            resources :docs, :controller => 'demos/docs'
            resources :fronts, :controller => 'demos/fronts' do
              collection do
                get :about, :sitemap
              end
            end
            resources :tools, :controller => 'demos/tools' do
              collection do
                get :map_list ,:geocode, :geo_form, :select
              end
              member do
                post :layer,:folder_list, :layer_list
              end
            end
            resources :inquiries, :controller => 'demos/inquiries'
            resources :searches, :controller => 'demos/searches'do
              collection do
                get :get_bbox
              end
            end

          end

        resources :background_maps
        resources :map_icons do
          member do
            get :icon
          end
        end
        resources :maps do
          collection do
            get :user_fields, :recognize_index, :publish
          end
          resources :legend_files, :controller => 'maps/legend_files'
          resources :searches, :controller => 'maps/searches'
          resources :related_links, :controller => 'maps/related_links'
          resources :portal_photos, :controller => 'maps/portal_photos'
          resources :recommends, :controller => 'maps/recommends'
          resources :configs, :controller=> 'maps/configs'
          resources :externals, :controller=> 'maps/externals'
          resources :recognizers, :controller => 'maps/recognizers' do
            member do
              get :recognize, :refuse
            end
            collection do
              get :publish
            end
          end
          resources :inquiries, :controller => 'maps/inquiries' do
            collection do
              get :get_info
            end
          end
          resources :social_updates, :controller => 'maps/social_updates' do
            collection do
              get :get_info
            end

          end
        end
        resources :recommends

        resources :mapfiles do
          collection do
            get :user_fields
          end
        end
        resources :mapfile_histories do
          member do
            get :restore
          end
        end
        resources :layers do
          collection do
            get :user_fields
          end
          resources :legend_files, :controller => 'layers/legend_files'
          resources :import_data, :controller => 'layers/import_data'
          resources :data, :controller => 'layers/data' do
            collection do
              get :csv_put, :get_center, :csv_up
              post :csv_up
            end
            member do
              post :photo_sort
            end
          end
          resources :columns, :controller => 'layers/columns'
          resources :legends, :controller => 'layers/legends'
        end
        resources :folders do
          collection do
            get :user_fields
          end
        end
      end
    end
  end

  match "gis/layers/:id/file"                               => "gis/public/files#layer_file"
  match "gis/legend_file/*path"                             => "gis/public/files#legend_file", :format => false
  match "gis/map_attach_file/*path"                         => "gis/public/files#map_attach_file", :format => false
  match "gis/layers/:id/photo"                              => "gis/public/files#photo"
  match "gis/layers/:id/thumbnail"                          => "gis/public/files#thumbnail"
  match "gis/layers/:id/original"                           => "gis/public/files#original"
  match "gis/demos/dual"                                    => "gis/public/demos#dual"
  match "gis/demos/dual_js(.:format)"                       => "gis/public/demos#dual_js"
  match ":code/layer(.:format)"                         => "gis/public/portals#layer"
  match ":code/layer_portal1(.:format)"                 => "gis/public/portals#layer_portal1"
  match ":code/extjs(.:format)"                         => "gis/public/portals#extjs"
  match ":code/dual(.:format)"                         => "gis/public/portals#dual"
  match ":code/dual_js(.:format)"                         => "gis/public/portals#dual_js"
  match ":code/extjs_portal1(.:format)"                 => "gis/public/portals#extjs_portal1"
  match ":code/draw(.:format)"                          => "gis/public/portals#draw"
  match ":code/measure(.:format)"                       => "gis/public/portals#measure"
  match ":code/export(.:format)"                        => "gis/public/portals#export"
  match ":code/:id/download_kml(.:format)"              => "gis/public/portals#download_kml"
  match ":code/:id/feature(.:format)"                   => "gis/public/portals#feature"
  match ":code/import(.:format)"                        => "gis/public/portals#import", defaults: { format: 'text' }
  match ":code/:id/legend(.:format)"                    => "gis/public/portals#legend"
  match ":code/:id/data(.:format)"                      => "gis/public/portals#data"
  match ":code/print(.:format)"                       => "gis/public/portals#print"
  match ":code/:id/export_form(.:format)"             => "gis/public/portals#export_form"
  match ":code/:id/output(.:format)"                  => "gis/public/portals#output"
  match ":code/feature_edit(.:format)"                => "gis/public/portals#feature_edit"
  match ":code/external(.:format)"                    => "gis/public/portals#external"
  match ":code/:id/slider(.:format)"                    => "gis/public/portals#slider"
  match ":code/:id/folder_remark(.:format)"            => "gis/public/portals#folder_remark"

  ## Indivisual Portal

  match ":code/sitemap.html"                          => "gis/public/portals/fronts#sitemap"
  match ":code/sitemap.html.r"                          => "gis/public/portals/fronts#sitemap"
  match ":code/about.html"                            => "gis/public/portals/fronts#about"
  match ":code/about.html.r"                            => "gis/public/portals/fronts#about"
  match ":code/doc/index(.:format)"                   => "gis/public/portals/docs#index"
  match ":code/doc/index.html.r"                      => "gis/public/portals/docs#index"
  match ":code/doc/:name"                             => "gis/public/portals/docs#show"
  match ":code/doc/:name/index.html.r"                => "gis/public/portals/docs#show"
  match ":code/search"                                => "gis/public/portals/searches#index"
  match ":code/search/get_bbox"                       => "gis/public/portals/searches#get_bbox"
  match ":code/search/spot/:id.html"                  => "gis/public/portals/searches#show"
  match ":code/search/spot/:id.html.r"                => "gis/public/portals/searches#show"
  match "gis/search/feature_:id(.:format)"            => "gis/public/tools#feature"


  match "gis/category"                                => "gis/public/categories#index"
  match "gis/category/index.html.r"                   => "gis/public/categories#index"
  match "gis/category/index.html"                     => "gis/public/categories#index"
  match "gis/category/:code"                          => "gis/public/categories#show"
  match "gis/category/:code/index.html.r"             => "gis/public/categories#show"
  match "gis/category/:code/index.html"               => "gis/public/categories#show"



  ## Geocoding API
  match 'gis/geocoding/'                            => 'gis/public/tools#geocode'
  match "gis/geo_form(.:format)"                    => "gis/public/tools#geo_form"

  ## LayerTool
  match "gis/tools/:id/folder_list"                  => 'gis/public/tools#folder_list'
  match "gis/tools/:id/layer_list"                   => 'gis/public/tools#layer_list'
  match "gis/tools/:id/layer"                        => 'gis/public/tools#layer'
  match "gis/tools/select"                           => 'gis/public/tools#select'

  match "gis/about(.:format)"                           => "gis/public/fronts#about"
  match "gis/about.html.r"                              => "gis/public/fronts#about"
  match "gis/use(.:format)"                             => "gis/public/fronts#use"
  match "gis/use.html.r"                                => "gis/public/fronts#use"
  match "gis/howto(.:format)"                           => "gis/public/fronts#howto"
  match "gis/howto.html.r"                              => "gis/public/fronts#howto"
  match "gis/help(.:format)"                           => "gis/public/fronts#help"
  match "gis/help.html.r"                              => "gis/public/fronts#help"
  match "gis/front/sitemap(.:format)"                   => "gis/public/fronts#sitemap"
  match "gis/front/sitemap.html.r"                      => "gis/public/fronts#sitemap"
  match "inquiry/index(.:format)"                       => "gis/public/inquiries#index"
  match "inquiry/index.html.r"                          => "gis/public/inquiries#index"
  match "doc/index(.:format)"                           => "gis/public/docs#index"
  match "doc/index.html.r"                              => "gis/public/docs#index"
  match "doc/information_:id(.:format)"                 => "gis/public/docs#redirect"
  match "doc/information_:id.html.r"                    => "gis/public/docs#redirect"
  match "doc/:name"                                     => "gis/public/docs#show"
  match "doc/:name/index.html.r"                        => "gis/public/docs#show"
  match "doc/:name/index.html"                          => "gis/public/docs#show"




  match "search/index(.:format)"     =>  'gis/public/searches#index'
  match "search/index.html.r"        =>  'gis/public/searches#index'

  match ":code/"                    =>  'gis/public/portals#index'
  match ":code/index.html.r"        =>  'gis/public/portals#index'
end
