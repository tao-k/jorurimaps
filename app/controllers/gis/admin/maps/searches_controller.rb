# encoding: utf-8
class Gis::Admin::Maps::SearchesController < Gis::Controller::Admin::Base
  include System::Controller::Scaffold
  include System::Controller::Admin::Auth
  layout "admin/gis/base"

  def initialize_scaffold
    @map = Gis::Map.where(:id => params[:map_id]).first
    return http_error(404) if @map.blank?
    Page.title = "#{@map.title} 検索フォーム設定"
    @is_role_admin = Core.user.has_auth?(:manager)
    get_layer_configs
  end

  def get_layer_configs
    @layers_configs = []
    @layers = []
    folders = @map.assortments
    folders.each do |folder|
      f_layers = folder.layers
      f_layers.each do |layer|
        next if layer.kind != "vector"
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
      @layers << layer
      @layers_configs << {
          :layer => layer,
          :columns => layer.get_search_column_select
        }
    end if layers

  end

  def index

    item = Misc::SearchColumn.new
    item.and :portal_id, @map.id
    item.page  params[:page], params[:limit]
    item.order params[:sort], :form_type
    @items = item.find(:all)
    _index @items
  end

  def show
    @item = Misc::SearchColumn.where(:id => params[:id]).first
    return http_error(404) if @item.blank?
    _show @item
  end

  def new
    @item = Misc::SearchColumn.new({
      :form_type => "area",
      :portal_id  => @map.id
    })
  end


  def edit
    @item = Misc::SearchColumn.where(:id => params[:id]).first
    return http_error(404) if @item.blank?
    return authentication_error(403) unless @item.editable?
  end

  def create
    @item = Misc::SearchColumn.new(params[:item])
    if @item.save_with_rels(params, :create)
      @item.cache_clear
      return redirect_to url_for(:action => :index)
    else
      return render :action => :new
    end
  end

  def update
    @item = Misc::SearchColumn.where(:id => params[:id]).first
    return http_error(404) if @item.blank?
    return authentication_error(403) unless @item.editable?
    @item.attributes = params[:item]
    if @item.save_with_rels(params, :update)
      @item.cache_clear
      return redirect_to url_for(:action => :index)
    else
      return render :action => :edit
    end
  end

  def destroy
    @item = Misc::SearchColumn.where(:id => params[:id]).first
    return http_error(404) if @item.blank?
    return authentication_error(403) unless @item.deletable?
    @item.cache_clear
    _destroy @item
  end


end
