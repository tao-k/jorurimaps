# encoding: utf-8
class Gis::Admin::Maps::ConfigsController< System::Controller::Admin::Base
  include System::Controller::Scaffold
  include System::Controller::Admin::Auth
  layout "admin/gis/base"

  def initialize_scaffold
    @map = Gis::Map.where(:id => params[:map_id]).first
    return http_error(404) if @map.blank?
    Page.title = "#{@map.title} 表示設定"
    @is_role_admin = Core.user.has_auth?(:manager)
    @item = Gis::MapConfig.where(:portal_id=>@map.id).first
    @item = Gis::MapConfig.new({:portal_id=>@map.id, :lng => Gis.defalut_position[:lng], :lat => Gis.defalut_position[:lat], :zoom => Gis.defalut_position[:zoom]})  if @item.blank?
    @visible_layers = @item.layers
    @baselayer = @item.base_layer || "webtis_monotone"
      @js   = [
              "/javascripts/jquery.min.js",
              "/javascripts/jquery-ui.js",
               "/openlayers/OpenLayers.js",                    # must
               "http://maps.google.com/maps/api/js?gl=JP&sensor=false&language=ja&region=jp",
               "/openlayers/lib/OpenLayers/Lang/ja.js"
              ]
    @css = [
      "/_common/themes/gis/css/map.css",
      "/_common/js/ExtJs/resources/css/ext-all.css",
      "/_common/js/ExtJs/resources/css/yourtheme.css"
    ]
  end



  def index
    return redirect_to url_for({:controller=>"gis/admin/maps",:action=>:show, :id=>@map.id})
  end

  def show
    return redirect_to url_for({:controller=>"gis/admin/maps",:action=>:show, :id=>@map.id})
  end


  def new
    #
  end
  def create
    @item.attributes = params[:item]
    @item.base_layer  = params[:item_base_layer]
    @item.layers = params[:item_layers]
    if @item.save
      return redirect_to url_for({:controller=>"gis/admin/maps/configs",:action=>:new})
    else
      return render :action => :new
    end
  end

  def edit
    return redirect_to url_for({:controller=>"gis/admin/maps",:action=>:show, :id=>@map.id})
  end


  def update
    return redirect_to url_for({:controller=>"gis/admin/maps",:action=>:show, :id=>@map.id})
  end

  def destroy
    #@item = Gis::MapsRecognizer.where(:rid => params[:id]).first
    #_destroy @item do
    #  #other_recognize = Gis::MapsRecognizer.count(:all, :conditions=>["portal_id = ?", @map.id])
    #end
    return redirect_to url_for({:controller=>"gis/admin/maps",:action=>:show, :id=>@map.id})
  end



end
