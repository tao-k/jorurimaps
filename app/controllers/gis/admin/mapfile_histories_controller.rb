# encoding: utf-8
class Gis::Admin::MapfileHistoriesController < Gis::Controller::Admin::Base
  include System::Controller::Scaffold
  include System::Controller::Admin::Auth
  include System::Controller::Admin::UserSelect
  include Gis::Controller::Admin::SideMenu
  layout :switch_layout

  def initialize_scaffold
    Page.title = "マップファイル管理 履歴"
    @is_role_admin = Core.user.has_auth?(:manager)
    if @is_role_admin==true
      @p_group_id = nz(params[:p_group_id],0)
    else
      @p_group_id = nz(params[:p_group_id],Site.user_group.id)
    end
    @model = Gis::MapfileHistory

  end

  def search_condition
    params[:limit]             = nz(params[:limit],@limit)
    params[:p_group_id]        = nz(params[:p_group_id],@p_group_id)
    #qsa = ['limit', 's_keyword' ,'p_state','p_kind','p_cat','p_type','p_group_id','p_connect']
    qsa = ['limit', 's_keyword','p_state','p_kind','p_cat','p_type','p_group_id','p_connect']
    @qs = qsa.delete_if{|x| nz(params[x],'')==''}.collect{|x| %Q(#{x}=#{params[x]})}.join('&')
  end


  def show
    @item = Gis::MapfileHistory.where(:id => params[:id]).first
    return http_error(404) if @item.blank?
    _show @item
  end

  def restore
    @item = Gis::MapfileHistory.where(:id => params[:id]).first
    return http_error(404) if @item.blank?
    @mapfile = Gis::Mapfile.where(:id=>@item.mapfile_id).first
    return http_error(404) if @mapfile.blank?
    @mapfile.body = @item.body
    @mapfile.save
    flash[:notice] = "マップファイルを指定したリビジョンに戻しました。"
    return redirect_to url_for(:action=>:show)
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
