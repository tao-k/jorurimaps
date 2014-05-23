# encoding: utf-8
class Gis::Admin::Demos::SearchesController < Gis::Controller::Admin::Base
  include Gis::MapHelper
  layout :switch_layout


  def pre_dispatch
    @map = Gis::Map.where(:code=>params[:demo_id]).first
    return http_error(404) if @map.blank?

    Page.title = "#{@map.title}"
  end


  def get_bbox
    bbox = params[:bbox]
    ids = params[:ids].split(/,/)
    bbox_set = bbox.split(/,/)
    layer_item = Gis::LayerDatum.new
    layer_item.and :rid, ids
    layer_item.and "sql", "g && ST_SetSRID(ST_MakeBox2D(ST_Point(#{bbox_set[0]}, #{bbox_set[1]}),ST_Point(#{bbox_set[2]} ,#{bbox_set[3]})), 4326)"
    item_count = layer_item.count(:all)
    respond_to do |format|
      format.text { render :text=>item_count }
    end
  end

  def get_layer_configs
    @layers_configs = []
    @layers = []
    folders = get_folders_from_item(@map, "internal")
    folders.each do |folder|
      f_layers = folder.layers
      f_layers.each do |layer|
        next if layer.kind != "vector"
        next if layer.public_state == "closed"
        next if layer.state != "enabled"
        @layers << layer
        @layers_configs << {
          :layer => layer,
          :columns => layer.get_search_column_select
        }
      end if f_layers
    end if folders
    layers = @map.layers
    layers.each do |layer|
      next if layer.kind != "vector"
      next if layer.public_state == "closed"
      next if layer.state != "enabled"
      @layers << layer
      @layers_configs << {
          :layer => layer,
          :columns => layer.get_search_column_select
        }
    end if layers
    @search_configs = Misc::SearchColumn.get_index_cache(@map)
  end


  def index
# 地図 リッチUI表示

    get_layer_configs
    layer_ids = @layers.map{|layer| layer.id}
    item = Gis::LayerDatum.new
    item.and :web_state , "public"
    item.and :state, "enabled"
    if params[:mode] && params[:mode] == "nearby" && params[:lat] && params[:lon]
      item.search_near_by params,layer_ids
    else
      item.public_search params,layer_ids
    end
    @items = item.find(:all)
    @layers_count = {}

    if request.smart_phone?
      @css = [
              "/javascripts/jquery.min.js",
              "/javascripts/jquery-ui.js",
              "/_common/themes/gis/css/smartphone_map.css",
              "/layout/gis/smartphone.css",
              "/_common/js/jquery/color_picker/colorPicker.css",
              "/_common/js/jquery/css/jquery-ui.css",
              '/_common/themes/gis/css/portal1/sm.css',
              "/_common/themes/gis/css/portal2_smartphone.css"
             ]
      @js   = [
               "/_common/js/proj4js/lib/proj4js-combined.js",   # must
               "/openlayers/OpenLayers.mobile_custom.js",                    # must
               "/_common/js/jquery/jquery-ui.min.js",
               "/_common/js/jquery/color_picker/jquery.colorPicker.min.js",
               "/_common/js/flipsnap.min.js",
               "http://maps.google.com/maps/api/js?gl=JP&sensor=false&language=ja&region=jp",
               "/_common/themes/gis/css/portal1/js/toogle-menu.js"
              ]
    else
      @css = [
              "/_common/js/ExtJs/resources/css/ext-all.css",   # must
              "/_common/js/ExtJs/resources/css/xtheme-access.css",  # ExtJs custom css
              "/_common/js/ExtJs/resources/css/xtheme-gray.css",     # ExtJs custom css
              "/_common/js/ExtJs/resources/css/xtheme-gray.css",     # ExtJs custom css
              "/_common/js/ExtJs/resources/css/yourtheme.css",       # my custom css
              "/_common/themes/gis/css/portal1/page/map.css",
              "/_common/themes/gis/css/portal1.css",
              '/_common/themes/gis/css/portal1/pc.css',
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
               "/_common/js/lightbox/js/lightbox.js",
               "/_common/js/lightbox/js/modernizr.custom.js",
               "/_common/js/scroll/js/imagesloaded.pkgd.min.js"
              ]
    end
    @portal = "portal1"
    @map_code = @map.code
    area_lat = nil
    area_lon = nil
    if params[:s_area_code]
      search_area = System::City.where(:rid=>params[:s_area_code]).first
      area_lat = search_area.lat if search_area
      area_lon = search_area.lng if search_area
    end
    @lat = area_lat || params[:lat]
    @lon = area_lon || params[:lon]
    @dynamic_js = [
                {:controller=> '/gis/admin/demos', :action => 'extjs', :id=>@map.code,
                  :lon=>@lon, :lat=>@lat, :zoom=>params[:zoom], :portal=>"portal2" ,
                  :code=>@map.code, :baselayer => params[:baselayer], :map_code=> @map.code}
              ]
    qs = "?s_area_code=#{params[:s_area_code]}"

    @qs = qs
    params.each do |v, s|
      if v =~ /s_custom_field_/
        @qs += "&#{v}=#{CGI.escape(s)}"
      end
    end

  end

  def show
    @js = [
       "/_common/js/lightbox/js/lightbox.js",
       "/_common/js/lightbox/js/modernizr.custom.js",
       "/_common/js/scroll/js/imagesloaded.pkgd.min.js"
    ]
        @css = [
      '/_common/themes/gis/css/portal1/page/map.css',
      "/_common/js/lightbox/css/lightbox.css"
      ]
    item = Gis::LayerDatum.new
    item.and :web_state , "public"
    item.and :state, "enabled"
    item.and :rid, params[:id]
    @item = item.find(:first)
    return http_error(404) if @item.blank?
  end

private


  def switch_layout
    case params[:action].to_s
    when 'index'
      "admin/gis/template/map_base"
    when 'get_bbox'
      "admin/gis/template/plain"
    when 'show'
      "admin/gis/template/portal1_1column"
    else
      "admin/gis/template/portal1"
    end
  end

end
