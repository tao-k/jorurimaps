# encoding: utf-8
class Gis::Admin::Demos::ToolsController < Gis::Controller::Admin::Base
  include Gis::MapHelper
  #layout "admin/ud"
  layout "public/gis/template/plain"

  def pre_dispatch
    @parent = Gis::Map.where(:code=>params[:demo_id]).first
    return http_error(404) if @parent.blank?

    Page.title = "#{@parent.title}"
    @js = [
      "/javascripts/main.js",
      "http://maps.google.com/maps/api/js?gl=JP&sensor=false&language=ja&region=jp"
      ]
    @is_role_admin = Core.user.has_auth?(:manager)
    if @is_role_admin==true
      @p_group_id = nz(params[:p_group_id],0)
    else
      @p_group_id = nz(params[:p_group_id],Site.user_group.id)
    end
  end

  def search_condition
    params[:limit]             = nz(params[:limit],@limit)
    params[:p_group_id]        = nz(params[:p_group_id],@p_group_id)
    qsa = ['limit', 's_keyword','p_state','p_kind','p_cat','p_type','p_group_id','p_connect']
    @qs = qsa.delete_if{|x| nz(params[x],'')==''}.collect{|x| %Q(#{x}=#{params[x]})}.join('&')
  end

  def map_list
    item = Gis::Map.new
    item.and :state, "enabled"
    web_state_cond = Condition.new()
    web_state_cond.and do |cond|
      cond.or :web_state ,"public"
      cond.or :web_state ,"internal"
      cond.or :web_state ,"recognize"
      cond.or :web_state ,"recognized"
    end
    item.and web_state_cond
    item.search params
    condition = Condition.new()
    condition.and do |cond|
      cond.or :portal_kind , 1
      cond.or :portal_kind , 2
    end
    item.and condition
    item.and "sql", "id != #{params[:exclude_id]}" unless params[:exclude_id].blank?
    @items = item.find(:all)
  end

  def folder_list
    @map = Gis::Map.where(:id => params[:id]).first
    return http_error(404) if @map.blank?
    @items = get_folders_from_item(@map, "internal")
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
  end



end
