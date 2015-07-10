# encoding: utf-8
class Gis::Admin::MapsController < Gis::Controller::Admin::Base
  include System::Controller::Scaffold
  include System::Controller::Admin::Auth
  include System::Controller::Admin::UserSelect
  include Gis::Controller::Admin::SideMenu
  layout :switch_layout

  def initialize_scaffold
    Page.title = Core.title
    @is_role_admin = Core.user.has_auth?(:manager)
    @p_group_id = nz(params[:p_group_id],0)
    @model = Gis::Map
    search_condition
  end

  def search_condition
    params[:limit]             = nz(params[:limit],@limit)
    params[:p_group_id]        = nz(params[:p_group_id],@p_group_id)
    qsa = ['limit', 's_keyword','p_state','p_kind','p_cat','p_type','p_group_id','p_connect']
    @qs = qsa.delete_if{|x| nz(params[x],'')==''}.collect{|x| %Q(#{x}=#{params[x]})}.join('&')
  end

  def index
    item = Gis::Map.new#.readable
    item.search params
    item.page  params[:page], params[:limit]
    item.order params[:sort], :sort_no
    @items = item.find(:all)
    _index @items
  end

  def recognize_index
    item = Gis::MapsRecognizer.new#.readable
    item.and :user_id, Core.user.id
    item.page  params[:page], params[:limit]
    item.order params[:sort], "recognized_at desc"
    @items = item.find(:all)
    _index @items
  end

  def show
    @item = Gis::Map.where(:id => params[:id]).first
    return http_error(404) if @item.blank?
    @folders = @item.assortments
    @relations = @item.relations
    @layers = @item.layers
    _show @item
  end

  def new
    @item = Gis::Map.new({
      :state        => 'enabled',
      :web_state    => 'internal',
      :user_kind    => 2,
      :portal_kind  => 2
    })
    @item.set_tmp_id
  end


  def edit
    @item = Gis::Map.where(:id => params[:id]).first
    return http_error(404) if @item.blank?
    return authentication_error(403) unless @item.editable?
    @a_folders = @item.get_maps_assortments(params)
    @a_relations = @item.get_maps_relations(params)
    @a_layers = @item.get_maps_layers(params)
    @item.set_tmp_id
  end

  def create
    upload_file = params[:item][:upload]
    thumb_upload_file = params[:item][:upload_thumb]
    params[:item].delete(:upload)
    params[:item].delete(:upload_thumb)
    @item = Gis::Map.new(params[:item])
    @a_folders = @item.get_maps_assortments(params)
    @a_layers = @item.get_maps_layers(params)
    @a_relations = @item.get_maps_relations(params)
    if @item.save_with_rels(params[:assortment],params[:layer],upload_file, params[:icon_delete],thumb_upload_file, params[:thumb_delete],params[:relation]  ,:create)
      @item.cache_clear
      return redirect_to url_for(:action => :index)
    else
      return render :action => :new
    end
  end

  def update
    @item = Gis::Map.where(:id => params[:id]).first
    return http_error(404) if @item.blank?
    return authentication_error(403) unless @item.editable?
    upload_file = params[:item][:upload]
    params[:item].delete(:upload)
    thumb_upload_file = params[:item][:upload_thumb]
    params[:item].delete(:upload_thumb)
    @item.attributes = params[:item]
    @a_folders = @item.get_maps_assortments(params)
    @a_layers = @item.get_maps_layers(params)
    if @item.save_with_rels(params[:assortment],params[:layer], upload_file, params[:icon_delete],thumb_upload_file, params[:thumb_delete],params[:relation] , :update)
      @item.cache_clear
      return redirect_to url_for(:action => :update)
    else
      return render :action => :edit
    end
  end

  def destroy
    @item = Gis::Map.where(:id => params[:id]).first
    return http_error(404) if @item.blank?
    return authentication_error(403) unless @item.deletable?
    _destroy @item do
      @item.cache_clear
    end
  end


private
  def switch_layout
    case params[:action].to_s
    when 'side_menu'
      "admin/gis/plain"
    when 'show'
      "admin/gis/base"
    when 'new'
      "admin/gis/base"
    when 'edit'
      "admin/gis/base"
    when 'create'
      "admin/gis/base"
    when 'update'
      "admin/gis/base"
    when 'recognize_index'
      "admin/gis/base"
    else
      "admin/gis/base_2_column"
    end
  end
end
