# encoding: utf-8
class Gis::Admin::Layers::LegendFilesController < Gis::Controller::Admin::Base
  include System::Controller::Scaffold
  include System::Controller::Admin::Auth
  layout "admin/gis/inline"

  def initialize_scaffold
    Page.title = "凡例添付ファイル管理"
    @is_role_admin = Core.user.has_auth?(:manager)
    if @is_role_admin==true
      @p_group_id = nz(params[:p_group_id],0)
    else
      @p_group_id = nz(params[:p_group_id],Site.user_group.id)
    end
    @model = Gis::LegendFile
  end

  def index
    item = Gis::LegendFile.new#.readable
    item.and :tmp_id , params[:layer_id]
    @items = item.find(:all)
    _index @items
  end


  def new
    @item = Gis::LegendFile.new({
      :tmp_id => params[:layer_id]
    })
  end


  def create
    @item = Gis::LegendFile.new()
    @item.tmp_id = params[:layer_id]
    if @item.save_with_file(params[:item])
      flash[:notice] = "ファイルを登録しました。"
    else
      flash[:notice] = "ファイルの登録に失敗しました。"
    end
    return redirect_to url_for(:action => :index)
  end

  def destroy
    @item = Gis::LegendFile.where(:id => params[:id]).first
    return http_error(404) if @item.blank?
    return authentication_error(403) unless @item.deletable?
    _destroy @item
  end

end
