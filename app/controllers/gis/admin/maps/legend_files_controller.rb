# encoding: utf-8
class Gis::Admin::Maps::LegendFilesController < Gis::Controller::Admin::Base
  include System::Controller::Scaffold
  include System::Controller::Admin::Auth
  layout "admin/gis/inline"

  def initialize_scaffold
    Page.title = "添付ファイル管理"
    @is_role_admin = Core.user.has_auth?(:manager)
    if @is_role_admin==true
      @p_group_id = nz(params[:p_group_id],0)
    else
      @p_group_id = nz(params[:p_group_id],Site.user_group.id)
    end
  end

  def index
    item = Gis::MapLegendFile.new#.readable
    item.and :tmp_id , params[:map_id]
    @items = item.find(:all)
    _index @items
  end


  def new
    @item = Gis::MapLegendFile.new({
      :tmp_id => params[:map_id]
    })
  end


  def create
    @item = Gis::MapLegendFile.new()
    @item.tmp_id = params[:map_id]
    if @item.save_with_file(params[:item])
      flash[:notice] = "ファイルを登録しました。"
    else
      flash[:notice] = "ファイルの登録に失敗しました。"
    end
    return redirect_to url_for(:action => :index)
  end

  def destroy
    @item = Gis::MapLegendFile.where(:id => params[:id]).first
    return http_error(404) if @item.blank?
    return authentication_error(403) unless @item.deletable?
    _destroy @item
  end

end
