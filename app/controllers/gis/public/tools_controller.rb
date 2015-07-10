# encoding: utf-8
class Gis::Public::ToolsController < Gis::Controller::Public::Base
  include Gis::MapHelper

  layout "public/gis/template/plain"

  def pre_dispatch

    @js = [
      "/javascripts/main.js",
      Gis.google_api_url
      ]

  end

  def map_list
    item = Gis::Map.new
    item.and :state, "enabled"
    item.and :web_state ,"public"
    condition = Condition.new()
    condition.and do |cond|
      cond.or :portal_kind , 1
      cond.or :portal_kind , 2
    end
    item.and condition
    item.and "sql", "id != #{params[:exclude_id].to_i}" unless params[:exclude_id].blank?
    @items = item.find(:all)
  end

  def folder_list
    @map = Gis::Map.where(:id => params[:id], :web_state => "public").first
    return http_error(404) if @map.blank?
    @items = get_folders_from_item(@map, "all")
    @items_array = []
    @items.each do |item|
      @items_array << {
        "title" => item.title,
        "id" => item.id
      }
    end
    if @map.layers
      @items_array << {
        "title" => "未分類",
        "id" => @map.id
      }
    end
    @items_json = {
      "items" => @items_array
    }
    respond_to do |format|
      format.json {render :json => @items_json}
    end
  end

  def layer_list
    if params[:no_category]
      @parent = Gis::Map.where(:id => params[:id], :web_state => "public").first
    else
      @parent = Gis::Assortment.where(:id => params[:id]).first
    end
    return http_error(404) if @parent.blank?
    @items = @parent.layers
    return http_error(404) if @items.blank?
    @items_array = []
    @items.each do |item|
      next if item.public_state != "all"
      @items_array << {
        "title" => item.title,
        "id" => item.id
      }
    end
    @items_json = {
      "items" => @items_array
    }
    respond_to do |format|
      format.json {render :json => @items_json}
    end
  end

  def layer
    @map = Gis::Map.where(:id => params[:map_id], :web_state => "public").first if params[:map_id]
    @folder = Gis::Assortment.where(:id => params[:folder_id]).first if params[:folder_id]
    @item = Gis::Layer.where(:id => params[:id], :public_state => "all").first
    if @folder.blank?
      @folder = {
        :id => nil,
        :title => "未分類"
      }
    end
    return http_error(404) if @item.blank?
    mapfile_name = nil
    mapfile_name = @item.mapfile.file_name if @item.mapfile
      @items_json = {
        "map" => {
          "id" => @map.id,
          "title"  => @map.title
        },
        "folder" => {
          "id" => @folder[:id],
          "title"  => @folder[:title]
        },
        "layer" => {
          "id" => @item.id,
          "title"  => @item.title,
          "code" => @item.code,
          "kind" => @item.kind,
          "mapfile" => mapfile_name,
          "layers" => @item.mapfile_layer_name,
          "url" => @item.layer_data_url,
          "opacity" => 0.7,
          "internal"=> @item.is_internal
        }
      }
    #layer_code, kind,layer_id, mapfile,title,layers,url
    respond_to do |format|
      format.json {render :json => @items_json}
    end
  end

  def geo_form
    #地名検索用フォーム
    @extra_geocoding = Application.config(:extra_geocoding, false)
  end



end
