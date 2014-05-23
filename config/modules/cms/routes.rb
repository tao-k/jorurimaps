JoruriMaps::Application.routes.draw do
  mod = "cms"
  scp = "admin"

 # map.cms_preview "/_preview/:site/*path",
 #   :controller => "cms/admin/preview"

  ## admin
  scope "_#{scp}" do
    namespace mod do
      scope :module => scp do
        ## admin

        resources "kana_dictionaries",
          :controller => "kana_dictionaries",
          :path => "kana_dictionaries" do
            collection do
              get :make, :test
              post :make, :test
            end
          end

        resources "portal_photos",
          :controller => "portal_photos",
          :path => "portal_photos"

      end
    end
  end

end