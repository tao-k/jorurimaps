# encoding: utf-8
class System::Admin::SocialUpdates::AttachFilesController < Gis::Controller::Admin::Base
  include System::Controller::Scaffold
  include System::Controller::Admin::Auth
  layout "admin/gis/inline"

  def initialize_scaffold
    Page.title = "更新情報添付ファイル管理"
    return authentication_error(403) unless Core.user.has_auth?(:manager)
    @is_role_admin = Core.user.has_auth?(:manager)
    if @is_role_admin==true
      @p_group_id = nz(params[:p_group_id],0)
    else
      @p_group_id = nz(params[:p_group_id],Site.user_group.id)
    end
    @model = Misc::SocialUpdatePhotos
    @parent_model = params[:model_name]
  end

  def index
    item = Misc::SocialUpdatePhotos.new#.readable
    item.and :tmp_id , params[:social_update_id]
    item.and :model_name, @parent_model
    @items = item.find(:all)

    @item = Misc::SocialUpdatePhotos.new({
      :tmp_id => params[:social_update_id],
      :model_name => @parent_model
    })

    _index @items
  end


  def new
    @item = Misc::SocialUpdatePhotos.new({
      :tmp_id => params[:social_update_id],
      :model_name => @parent_model
    })
  end


  def create
    @item = Misc::SocialUpdatePhotos.new()
    @item.tmp_id = params[:social_update_id]
    if @item.save_with_file(params[:item])
      flash[:notice] = "ファイルを登録しました。"
    else
      flash[:notice] = "ファイルの登録に失敗しました。"
    end
    return redirect_to url_for(:action => :index, :model_name=>@item.model_name)
  end

  def destroy
    @item = Misc::SocialUpdatePhotos.where(:id => params[:id]).first
    return http_error(404) if @item.blank?
    return authentication_error(403) unless @item.deletable?
    @item.destroy
    flash[:notice] = "ファイルを削除しました。"
    return redirect_to url_for(:action => :index, :model_name=>@item.model_name)
  end

end
