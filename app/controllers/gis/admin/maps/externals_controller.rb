# encoding: utf-8
class Gis::Admin::Maps::ExternalsController< System::Controller::Admin::Base
  include System::Controller::Scaffold
  include System::Controller::Admin::Auth
  layout "admin/gis/base"

  def initialize_scaffold
    @map = Gis::Map.where(:id => params[:map_id]).first
    return http_error(404) if @map.blank?
    Page.title = "#{@map.title} 埋め込み用URL発行"
    @is_role_admin = Core.user.has_auth?(:manager)

      @js   = [
               "/_common/js/proj4js/lib/proj4js-combined.js",   # must
              "/javascripts/jquery.min.js",
              "/javascripts/jquery-ui.js",
               "/openlayers/OpenLayers.js",                    # must
               Gis.google_api_url,
               "/openlayers/lib/OpenLayers/Lang/ja.js"
              ]
    @css = [
      "/_common/themes/gis/css/map.css",
      "/_common/js/ExtJs/resources/css/ext-all.css",
      "/_common/js/ExtJs/resources/css/yourtheme.css"
    ]

  end



  def index
    @width = 720
    @height = 540
    @site_url = Core.full_uri
    @external_url = "#{@site_url}#{@map.code}/external"
    @external_tag = %Q(<iframe src="#{@external_url}" name="sample" width="#{@width}" height="#{@height}" frameborder="0" scrolling="no">)
    @external_tag += %Q(ブラウザがインラインフレームに対応していません。)
    @external_tag += %Q(</iframe>)
    @conf_item = Gis::MapConfig.where(:portal_id=>@map.id).first
    if @conf_item.blank?
      @visible_layers = []
      @baselayer = "webtis_monotone"
    else
      @visible_layers = @conf_item.layers
      @baselayer = @conf_item.base_layer || "webtis_blank"
    end

    @item = Gis::MapConfig.new

    @vector_layer_list = []


  end

  def show
    return redirect_to url_for({:controller=>"gis/admin/maps",:action=>:show, :id=>@map.id})
  end


  def new
    #
  end
  def create
    return redirect_to url_for({:controller=>"gis/admin/maps",:action=>:show, :id=>@map.id})
  end

  def edit
    return redirect_to url_for({:controller=>"gis/admin/maps",:action=>:show, :id=>@map.id})
  end


  def update
    return redirect_to url_for({:controller=>"gis/admin/maps",:action=>:show, :id=>@map.id})
  end

  def destroy
    return redirect_to url_for({:controller=>"gis/admin/maps",:action=>:show, :id=>@map.id})
  end



end
