# encoding: utf-8
module Gis::Controller::Public::Map



  def feature_edit
    #
  end

  def external
    @css = [
              "/_common/js/ExtJs/resources/css/ext-all.css",   # must
              "/_common/js/ExtJs/resources/css/yourtheme.css",       # my custom css
              "/_common/themes/gis/css/map.css",
              "/_common/themes/gis/css/portal2.css",
              "/layout/gis/public.css"
             ]
      @js   = [
               "/_common/js/proj4js/lib/proj4js-combined.js",   # must
               "/openlayers/OpenLayers.js",                    # must
               "/_common/js/ExtJs/adapter/ext/ext-base.js",    # must
               Gis.google_api_url,
               "/openlayers/lib/OpenLayers/Lang/ja.js"
              ]
    @width = params[:width].to_i == 0 ? 650 : params[:width].to_i
    @height = params[:height].to_i == 0 ? 500 : params[:height].to_i

    @real_width = @width - 2
    @real_height = @height - 2

    @init_map = {:center_lon => Gis.defalut_position[:lng], :center_lat => Gis.defalut_position[:lat], :zoomlevel => Gis.defalut_position[:zoom] }

    @init_map[:center_lon] = params[:lon] unless params[:lon].blank?
    @init_map[:center_lat] = params[:lat] unless params[:lat].blank?
    @init_map[:zoomlevel] = params[:zoom] if params[:zoom] =~ /[0-9]+/ unless params[:zoom].blank?

    @layers = []
    @layers = params[:layers].split(",") unless params[:layers].blank?
    @portal = params[:portal].blank? ? "portal1" : params[:portal]
    @baselayer = params[:baselayer].blank? ? "" : params[:baselayer]


    @vector_layer_list = []


  end

  def print
    Page.title = "印刷プレビュー"

    @css = [
              "/_common/js/ExtJs/resources/css/ext-all.css",   # must
              "/_common/js/ExtJs/resources/css/yourtheme.css",       # my custom css
              "/_common/themes/gis/css/map.css",
              "/_common/themes/gis/css/portal2.css",
              "/layout/gis/public.css"
             ]
      @js   = [
               "/_common/js/proj4js/lib/proj4js-combined.js",   # must
               "/openlayers/OpenLayers.js",                    # must
               "/_common/js/ExtJs/adapter/ext/ext-base.js",    # must
               "/_common/js/ExtJs/ext-all.js",                 # must
               "/_common/js/GeoExt/script/GeoExt.js",          # must
               Gis.google_api_url,
               "/openlayers/lib/OpenLayers/Lang/ja.js"
              ]

    @map = Gis::Map.where(:code=>params[:code]).first
    @init_map = {:center_lon => Gis.defalut_position[:lng], :center_lat => Gis.defalut_position[:lat], :zoomlevel => Gis.defalut_position[:zoom] }

    @init_map[:center_lon] = params[:lon] unless params[:lon].blank?
    @init_map[:center_lat] = params[:lat] unless params[:lat].blank?
    @init_map[:zoomlevel] = params[:zoom] if params[:zoom] =~ /[0-9]+/ unless params[:zoom].blank?

    @layers = []
    @layers = params[:layers].split(",") unless params[:layers].blank?
    @portal = params[:portal].blank? ? "portal1" : params[:portal]
    @baselayer = params[:baselayer].blank? ? "" : params[:baselayer]

    @vector_layer_list = []

  end

  def base_layer
    #
  end

  def measure
    #
  end
  def folder_remark
    @item = Gis::Assortment.where(:id=>params[:id]).first
    return http_error(404) if @item.blank?
    return http_error(404) if @item.web_state == "closed"
  end

  def legend
    @item = Gis::Layer.where(:code=>params[:id]).first
    return http_error(404) if @item.blank?
  end


  def extjs
    @map = Gis::Map.where(:code=>params[:code], :web_state => "public").first
    return http_error(404) if @map.blank?

    Page.title = "#{@map.title}"

    get_js_params
  end
  def dual_js
    @map = Gis::Map.where(:code=>params[:code], :web_state => "public").first
    return http_error(404) if @map.blank?

    Page.title = "#{@map.title}"

    get_js_params
   #@init_map[:zoomlevel] =  @init_map[:zoomlevel].to_i + 10 if params[:baselayer] && params[:baselayer] == "webtis_blank"

  end
  def get_js_params
    @init_map = {:center_lon => Gis.defalut_position[:lng], :center_lat => Gis.defalut_position[:lat], :zoomlevel => Gis.defalut_position[:zoom] }

    map_config = @map.config
    @layers = []
    @baselayer = "gmap"
    unless map_config.blank?
      @init_map[:center_lon] = map_config.lng if map_config.lng
      @init_map[:center_lat] = map_config.lat if map_config.lat
      @init_map[:zoomlevel] = map_config.zoom if map_config.zoom
      @layers = map_config.layers
      @baselayer = map_config.base_layer
      params[:layers] = @layers.join(",") if params[:layers].blank? && !@layers.blank?
    end
    @layers = params[:layers].split(",") unless params[:layers].blank?
    @init_map[:center_lon] = params[:lon] unless params[:lon].blank?
    @init_map[:center_lat] = params[:lat] unless params[:lat].blank?
    @init_map[:zoomlevel] = params[:zoom] if params[:zoom] =~ /[0-9]+/ unless params[:zoom].blank?
    @portal = case @map.portal_kind
    when 1
      "portal1"
    else
      "portal2"
    end
    @baselayer = params[:baselayer].blank? ? @baselayer : params[:baselayer]
    @vector_layer_list = []
  end


  def portal1
     @css = [
      '/_common/themes/gis/css/portal1/page/top.css'
      ]
    @docs = Misc::SocialUpdate.get_index_cache(@map)
    @search_configs = Misc::SearchColumn.get_index_cache(@map)
  end

  def dual
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
              "/_common/js/lightbox/css/lightbox.css"#,
              #"/_common/js/lightbox/css/screen.css"*/
             ]
      @js   = [
               "/_common/js/proj4js/lib/proj4js-combined.js",   # must
               #"/openlayers/OpenLayers.js",                    # must
               "/openlayers/OpenLayers.js",                    # must
               "/_common/js/webtis/webtis_next.js",            # must
               "/_common/js/ExtJs/adapter/ext/ext-base.js",    # must
               "/_common/js/ExtJs/ext-all.js",                 # must
               "/_common/js/GeoExt/script/GeoExt.js",          # must
               Gis.google_api_url,
               "/openlayers/lib/OpenLayers/Lang/ja.js",
               "/_common/js/scroll/js/jquery.mousewheel.min.js",
               "/_common/js/scroll/js/jquery.smoothdivscroll-1.3-min.js",
               "/_common/js/lightbox/js/lightbox.js",
               "/_common/js/lightbox/js/modernizr.custom.js",
               "/_common/js/scroll/js/imagesloaded.pkgd.min.js"
              ]
    @portal = "portal2"

    @dynamic_js = [
                {:controller=> 'gis/public/portals', :action => 'dual_js', :lon=>params[:lon], :lat=>params[:lat], :zoom=>params[:zoom], :portal=>"portal2" , :code=>@map.code, :baselayer => params[:baselayer]}
              ]
  end


  def portal2
    # 地図 リッチUI表示
    if request.smart_phone?
      @css = [
              "/_common/themes/gis/css/smartphone_map.css",
              "/layout/gis/smartphone.css",
              "/_common/js/jquery/color_picker/colorPicker.css",
              "/_common/js/jquery/css/jquery-ui.css",
              "/_common/themes/gis/css/portal2_smartphone.css"
             ]
      @js   = [
               "/_common/js/proj4js/lib/proj4js-combined.js",   # must
               "/openlayers/OpenLayers.mobile_custom.js",                    # must
               "/_common/js/jquery/jquery-ui.min.js",
               "/_common/js/jquery/color_picker/jquery.colorPicker.min.js",
               "/_common/js/flipsnap.min.js",
               Gis.google_api_url,
               "/_common/js/jquery.jscrollpane.min.js"
              ]
    else
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
               "/_common/js/proj4js/lib/proj4js-combined.js",   # must
               "/openlayers/OpenLayers.js",                    # must
               "/_common/js/ExtJs/adapter/ext/ext-base.js",    # must
               "/_common/js/ExtJs/ext-all.js",                 # must
               "/_common/js/GeoExt/script/GeoExt.js",          # must
               Gis.google_api_url,
               "/openlayers/lib/OpenLayers/Lang/ja.js",
               "/_common/js/scroll/js/jquery.mousewheel.min.js",
               "/_common/js/scroll/js/jquery.smoothdivscroll-1.3-min.js",
               "/_common/js/lightbox/js/lightbox.js",
               "/_common/js/lightbox/js/modernizr.custom.js",
               "/_common/js/scroll/js/imagesloaded.pkgd.min.js"
              ]
    end
    @portal = "portal2"

    @dynamic_js = [
                {:controller=> 'gis/public/portals', :action => 'extjs', :lon=>params[:lon], :lat=>params[:lat], :zoom=>params[:zoom], :portal=>"portal2" , :code=>@map.code, :baselayer => params[:baselayer]}
              ]
  end

  def data
    @item_map = params[:map_code].blank? ? nil : Gis::Map.where(:code=>params[:map_code]).first
    @item = Gis::LayerDatum.find(:first, :conditions=>["rid = ? and web_state = ? and state = ?", params[:id], "public", "enabled"])
    @layer = @item.layer
    @layer_name = ""
    @layer_name = @layer.title unless @layer.blank?
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

  def download_kml
    tmp_path = "#{Rails.root.to_s}"
    tmp_path += "/" unless tmp_path.ends_with?('/')
    tmp_derectory = tmp_path  + "upload/export/#{params[:id]}/"
    tmp_path += "upload/export/#{params[:id]}/export.kml"
    if File.exist?(tmp_path)
      tmp_data = nil
      File.open(tmp_path){|f|
        tmp_data = f.read
       }
      dirlist = Dir::glob(tmp_derectory + "**/").sort {
        |a,b| b.split('/').size <=> a.split('/').size
      }
      dirlist.each {|d|
        Dir::foreach(d) {|f|
          File::delete(d+f) if ! (/\.+$/ =~ f)
        }
        Dir::rmdir(d)
      }
      respond_to do |format|
        format.xml do
          send_data(tmp_data,
              :type => 'text/csv',
              :disposition => 'attachment',
              :filename => "export.kml",
              :type=>'application/vnd.google-earth.kml+xml; charset=Shift_JIS')
        end
      end
    else
      return http_error(404)
    end
  end

  def import
    xml_string = "NG"
    if params[:item] && params[:item][:file]
      total_size = params[:item][:file].size
      total_size_limit = "5 MB"
      limit_value = total_size_limit.gsub(/(.*?)[^0-9].*/, '\\1').to_i * (1024**2)
      if total_size > limit_value
        xml_string = "NG"
      else
        xml_string = params[:item][:file].read
      end
    else
      xml_string = "NG"
    end


    respond_to do |format|
      format.text {render :text => xml_string}
    end
  end


  def layer
    @visible_layers = params[:layers]
  end

  def export_form
    @item = Gis::Layer.where(:code => params[:id]).first
    return http_error(404) if @item.blank?
    return http_error(404) if @item.public_state != "all"
  end

  def output
    @item = Gis::Layer.where(:id => params[:id]).first
    return http_error(404) if @item.blank?
    return http_error(404) if @item.public_state != "all"


    #IE判定
    user_agent = request.headers['HTTP_USER_AGENT']
    chk = user_agent.index("MSIE")
    chk = user_agent.index("Trident") if chk.blank?
    time_str = Time.now.strftime("%Y年%m月%d日_%H時%M分")
    item_filename = "#{@item.title}_登録データ一覧（ラベルあり）_#{time_str}.kml"
    item_filename = "#{@item.title}_登録データ一覧（ラベルなし）_#{time_str}.kml" if params[:kml_no_label]
    item_filename = "#{@item.title}_登録データ一覧_#{time_str}.csv" if params[:csv]
    if chk.blank?
      item_filename = item_filename
    else
      item_filename = item_filename.tosjis
    end


    full_uri = Core.full_uri
    full_uri = full_uri.chop if full_uri.ends_with?('/')

    if params[:csv]

      options = {:url => full_uri}
      csv_string = Gis::Script::Export::Csv.export_csv(@item, options)
      csv_string = csv_string.tosjis
      return send_data(csv_string,
              :disposition => 'attachment',
              :filename => item_filename,
              :type => 'text/csv; charset=Shift_JIS')
    end
    if params[:kml] || params[:kml_no_label]
      options = {:url => full_uri}
      options[:no_label] = true if params[:kml_no_label]
      xml_obj = Gis::Script::Export::Kml.export_kml(@item, options)
      return send_data(xml_obj,
              :disposition => 'attachment',
              :filename => item_filename,
              :type=>'application/vnd.google-earth.kml+xml; charset=utf-8')
    end

  end

  def slider
    @item = Gis::Layer.where(:code => params[:id]).first
    return http_error(404) if @item.blank?
    return http_error(404) if @item.public_state != "all"
    layer_check = Gis::Script::Export::Csv.get_layer_items(@item)
    @layer_kind =  layer_check[:layer_kind]
    @items = layer_check[:items]
  end


end
