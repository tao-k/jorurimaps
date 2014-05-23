# encoding: utf-8
class Gis::Admin::DemosController < Gis::Controller::Admin::Base
  include System::Model::FileUtil

  #layout "admin/ud"
  layout :switch_layout

  def pre_dispatch
    @system_cities = System::City.find(:all, :order=>:sort_no)
  end

  def show
    @map = Gis::Map.where(:code=>params[:id]).first
    return http_error(404) if @map.blank?
    Page.title = "#{@map.title}"
    case @map.portal_kind
    when 1
      portal1
    when 2
     portal2
    when 3
      portal_page
    when 4
      portal_page
    else
      #
    end
  end

  def portal1
     @css = [
      '/_common/themes/gis/css/portal1/page/top.css'
      ]
    @docs = Misc::SocialUpdate.get_index_cache(@map)
    @search_configs = Misc::SearchColumn.get_index_cache(@map)
  end


  def portal_page
    @css = [
      "/_common/themes/gis/css/page/doc.css"
    ]

  end


  def view
    @cities = System::City.find(:all, :order=>:sort_no)
  end

  def bbox
    #
  end

  def feature_edit
    #
  end

  def base_layer
    #
  end

  def measure
    #
  end


  def extjs
    @map = Gis::Map.where(:code=>params[:id]).first
    return http_error(404) if @map.blank?
    Page.title = "#{@map.title}"
    @vector_layer_list = []
    @init_map = {:center_lon => Gis.defalut_position[:lng], :center_lat => Gis.defalut_position[:lat], :zoomlevel => Gis.defalut_position[:zoom] }



    map_config = @map.config
    @layers = []
    @baselayer = "gmap"
     if @map.web_state != "public"
       @baselayer = "webtis_monotone"
       @init_map[:zoomlevel] = 9
     end
    unless map_config.blank?
      @init_map[:center_lon] = map_config.lng if map_config.lng
      @init_map[:center_lat] = map_config.lat if map_config.lat
      @init_map[:zoomlevel] = map_config.zoom if map_config.zoom

      @layers = map_config.layers
      @baselayer = map_config.base_layer
      params[:layers] = @layers.join(",") if params[:layers].blank? && !@layers.blank?
    end

    @init_map[:center_lon] = params[:lon] unless params[:lon].blank?
    @init_map[:center_lat] = params[:lat] unless params[:lat].blank?
    @init_map[:zoomlevel] = params[:zoom] if params[:zoom] =~ /[0-9]+/ unless params[:zoom].blank?
    @layers = params[:layers].split(",") unless params[:layers].blank?
    @portal = params[:portal].blank? ? "portal1" : params[:portal]
    @baselayer = params[:baselayer] unless params[:baselayer].blank?
  end

  def dual_js
    @init_map = {:center_lon => Gis.defalut_position[:lng], :center_lat => Gis.defalut_position[:lat], :zoomlevel => Gis.defalut_position[:zoom] }

  end

  def portal2
    # 地図 リッチUI表示
    @layers = params[:layers]
      @css = [
              "/_common/js/ExtJs/resources/css/ext-all.css",   # must
              "/_common/js/ExtJs/resources/css/xtheme-access.css",  # ExtJs custom css
              "/_common/js/ExtJs/resources/css/xtheme-gray.css",     # ExtJs custom css
              "/_common/js/ExtJs/resources/css/xtheme-gray.css",     # ExtJs custom css
              "/_common/js/ExtJs/resources/css/yourtheme.css",       # my custom css
              "/_common/themes/gis/css/map.css",
              "/_common/themes/gis/css/portal2.css",
              "/layout/gis/public.css",
              "/_common/js/scroll/css/smoothDivScroll.css",
              "/_common/js/lightbox/css/lightbox.css"
             ]
      @js   = [
              "/javascripts/jquery.min.js",
              "/javascripts/jquery-ui.js",
               "/_common/js/proj4js/lib/proj4js-combined.js",   # must
               "/openlayers/OpenLayers.js",                    # must
               "/_common/js/ExtJs/adapter/ext/ext-base.js",    # must
               "/_common/js/ExtJs/ext-all.js",                 # must
               "/_common/js/GeoExt/script/GeoExt.js",          # must
               "http://maps.google.com/maps/api/js?gl=JP&sensor=false&language=ja&region=jp",
               "/openlayers/lib/OpenLayers/Lang/ja.js",
               "/_common/js/scroll/js/jquery.mousewheel.min.js",
               "/_common/js/scroll/js/jquery.smoothdivscroll-1.3-min.js",
               "/_common/js/lightbox/js/lightbox.js",
               "/_common/js/lightbox/js/modernizr.custom.js",
               "/_common/js/scroll/js/imagesloaded.pkgd.min.js"
              ]

    # コントローラ経由でJSファイルを生成する
    @dynamic_js = [
                {:controller=> 'gis/admin/demos', :action => 'extjs', :id=>@map.code }
              ]

  end

  def dual
    # 地図 リッチUI表示

    @css = [
            "/_common/js/ExtJs/resources/css/ext-all.css",   # must
            "/_common/js/ExtJs/resources/css/xtheme-access.css",  # ExtJs custom css
            "/_common/js/ExtJs/resources/css/xtheme-gray.css",     # ExtJs custom css
            "/_common/js/ExtJs/resources/css/xtheme-gray.css",     # ExtJs custom css
            "/_common/js/ExtJs/resources/css/yourtheme.css",       # my custom css
            "/_common/themes/gis/css/map.css"
           ]
    @js   = [
             "/_common/js/proj4js/lib/proj4js-combined.js",   # must
             "/openlayers/OpenLayers.js",                    # must
             "/_common/js/ExtJs/adapter/ext/ext-base.js",    # must
             "/_common/js/ExtJs/ext-all.js",                 # must
             "/_common/js/GeoExt/script/GeoExt.js",          # must
             "http://maps.google.com/maps/api/js?gl=JP&sensor=false&language=ja&region=jp"
            ]

    @dynamic_js = [
                {:controller=> 'gis/admin/demos', :action => 'dual_js' }
              ]

  end



  def data
    @item_map = params[:map_code].blank? ? nil : Gis::Map.where(:code=>params[:map_code]).first
    @item = Gis::LayerDatum.find(:first, :conditions=>["rid = ? and web_state = ? and state = ?", params[:id], "public", "enabled"])
    return http_error(404) if @item.blank?
    if params[:portal_layers]
      portal_layers = params[:portal_layers].split(/,/)
      @item_map = nil if portal_layers.index(@item.layer.code).blank?
    end
  end
  def export
    xml_string = params[:kml_data]
    tmp_path = "#{Rails.root.to_s}"
    tmp_path += "/" unless tmp_path.ends_with?('/')
    current_time = Time.now.to_i
    download_path = "/export/#{current_time}/export.kml"
    tmp_path += "upload/export/#{current_time}/export.kml"
    #item_filename = "export#{Time.now.to_i}.kml"
    mkdir_for_file(tmp_path)
    File.open(tmp_path, 'wb') { |f|
            f.write xml_string.html_safe
          }
    render :text => current_time
  end

  def import
    xml_string = params[:file]
    render :text => xml_string
  end

  def download_kml
    tmp_path = "#{Rails.root.to_s}"
    tmp_path += "/" unless tmp_path.ends_with?('/')
    tmp_path += "upload/export/#{params[:id]}/export.kml"
    if File.exist?(tmp_path)
      respond_to do |format|
        format.xml do
          send_file(tmp_path, :filename => "export.kml", :disposition => 'attachment', :type=>'application/vnd.google-earth.kml+xml; charset=Shift_JIS', :x_sendfile => true)
        end
      end
    else
      return http_error(404)
    end
  end

  def import
    #
  end

  def layer
    @map = Gis::Map.where(:id=>params[:map_id]).first
    @visible_layers = params[:layers].split(",")
  end



  def legend
    @item = Gis::Layer.where(:code=>params[:id]).first
    return http_error(404) if @item.blank?
  end

  def slider
    @item = Gis::Layer.where(:code => params[:id]).first
    return http_error(404) if @item.blank?
    layer_check = Gis::Script::Export::Csv.get_layer_items(@item)
    @layer_kind =  layer_check[:layer_kind]
    @items = layer_check[:items]
  end

private
  def switch_layout

    case params[:action].to_s
    when 'show'
      if @map.portal_kind == 1
        "admin/gis/template/portal1"
      elsif @map.portal_kind == 2
        "admin/template/demo_map"
      elsif @map.portal_kind == 3 || @map.portal_kind == 4
        "admin/gis/template/doc"
      end
    when 'dual'
      "admin/template/dual_map"
    when 'layer'
      "admin/gis/plain"
    when 'legend'
      "admin/gis/plain"
    when 'draw'
      "admin/gis/plain"
    when 'base_layer'
      "admin/gis/plain"
    when 'measure'
      "admin/gis/plain"
    when 'slider'
      "admin/gis/plain"
    when 'feature_edit'
      "admin/gis/plain"
    else
      "admin/gis/base"
    end


  end

end
