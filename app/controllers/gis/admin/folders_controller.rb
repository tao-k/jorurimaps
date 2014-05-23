# encoding: utf-8
class Gis::Admin::FoldersController < Gis::Controller::Admin::Base
  include System::Controller::Scaffold
  include System::Controller::Admin::Auth
  include System::Controller::Admin::UserSelect
  include Gis::Controller::Admin::SideMenu
  layout :switch_layout

  def initialize_scaffold
    Page.title = "フォルダ管理"
    @is_role_admin = Core.user.has_auth?(:manager)
    if @is_role_admin==true
      @p_group_id = nz(params[:p_group_id],0)
    else
      @p_group_id = nz(params[:p_group_id],Site.user_group.id)
    end
    @model = Gis::Assortment
    search_condition
  end

  def search_condition
    params[:limit]             = nz(params[:limit],@limit)
    params[:p_group_id]        = nz(params[:p_group_id],@p_group_id)
    qsa = ['limit', 's_keyword','p_state','p_kind','p_cat','p_type','p_group_id','p_connect']
    @qs = qsa.delete_if{|x| nz(params[x],'')==''}.collect{|x| %Q(#{x}=#{params[x]})}.join('&')
  end

  def index
    item = Gis::Assortment.new#.readable
    item.search params
    item.page  params[:page], params[:limit]
    item.order params[:sort], :updated_at
    @items = item.find(:all)
    _index @items
  end

  def show
    @item = Gis::Assortment.where(:id => params[:id]).first
    @layers = @item.layers
    @maps  = @item.maps
    _show @item
  end

  def edit
    @item = Gis::Assortment.where(:id => params[:id]).first
    return http_error(404) if @item.blank?
    return authentication_error(403) unless @item.editable?
    @a_layers = @item.get_assortments_layers(params)
  end


  def new
    @item = Gis::Assortment.new({
      :user_kind    => 2,
      :web_state    => "all"
    })
    @a_layers = @item.get_assortments_layers(params)
  end

  def create
    @item = Gis::Assortment.new(params[:item])
    @a_layers = @item.get_assortments_layers(params)
    if @item.save_with_rels(params[:layer], :create)
      @item.cache_clear
      return redirect_to url_for(:action => :index)
    else
      return render :action => :edit
    end
  end

  def update
    @item = Gis::Assortment.where(:id => params[:id]).first
    return http_error(404) if @item.blank?
    return authentication_error(403) unless @item.editable?
    @item.attributes = params[:item]
    @a_layers = @item.get_assortments_layers(params)
    if @item.save_with_rels(params[:layer], :update)
      @item.cache_clear
      return redirect_to url_for(:action => :update)
    else
      return render :action => :edit
    end
  end

  def destroy
    @item = Gis::Assortment.where(:id => params[:id]).first
    return http_error(404) if @item.blank?
    return authentication_error(403) unless @item.deletable?
    _destroy @item do
      cache_item = Gis::Assortment.new
      cache_item.cache_clear
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
    else
      "admin/gis/base_2_column"
    end
  end

end
