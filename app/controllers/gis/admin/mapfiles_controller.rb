# encoding: utf-8
class Gis::Admin::MapfilesController < Gis::Controller::Admin::Base
  include System::Controller::Scaffold
  include System::Controller::Admin::Auth
  include System::Controller::Admin::UserSelect
  include Gis::Controller::Admin::SideMenu
  layout :switch_layout

  def initialize_scaffold
    Page.title = "マップファイル管理"
    @is_role_admin = Core.user.has_auth?(:manager)
    if @is_role_admin==true
      @p_group_id = nz(params[:p_group_id],0)
    else
      @p_group_id = nz(params[:p_group_id],Site.user_group.id)
    end
    @model = Gis::Mapfile
    search_condition
  end

  def search_condition
    params[:limit]             = nz(params[:limit],@limit)
    params[:p_group_id]        = nz(params[:p_group_id],@p_group_id)
    qsa = ['limit', 's_keyword','p_state','p_kind','p_cat','p_type','p_group_id','p_connect']
    @qs = qsa.delete_if{|x| nz(params[x],'')==''}.collect{|x| %Q(#{x}=#{params[x]})}.join('&')
  end

  def index
    item = Gis::Mapfile.new#.readable
    item.search params
    item.page  params[:page], params[:limit]
    item.order params[:sort], "file_name"
    @items = item.find(:all)
    _index @items
  end

  def show
    @item = Gis::Mapfile.where(:id => params[:id]).first
    return http_error(404) if @item.blank?

    item = Gis::MapfileHistory.new#.readable
    item.page  params[:page], 10
    item.and :mapfile_id , @item.id
    item.order "updated_at desc"
    @histories = item.find(:all)

    _show @item
  end

  def new
    @item = Gis::Mapfile.new({
      :state        => 'enabled',
      :user_kind    => 2
    })
  end

  def create
    @item = Gis::Mapfile.new(params[:item])
    _create @item do
      @item.save_history
    end
  end

  def edit
    @item = Gis::Mapfile.where(:id => params[:id]).first
    return http_error(404) if @item.blank?
    return authentication_error(403) unless @item.editable?
  end

  def update
    @item = Gis::Mapfile.where(:id => params[:id]).first
    return http_error(404) if @item.blank?
    return authentication_error(403) unless @item.editable?
    @item.attributes = params[:item]
    _update @item do
      @item.save_history
    end
  end

  def destroy
    @item = Gis::Mapfile.where(:id => params[:id]).first
    return http_error(404) if @item.blank?
    return authentication_error(403) unless @item.deletable?
    _destroy @item
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
