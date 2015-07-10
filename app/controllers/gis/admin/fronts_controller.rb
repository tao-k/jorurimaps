# encoding: utf-8
class Gis::Admin::FrontsController < Gis::Controller::Admin::Base
  include System::Controller::Scaffold

  layout "admin/gis/base"

  def initialize_scaffold
    Page.title = "地図情報データベース"
    @js = ["/javascripts/main.js",Gis.google_api_url]
  end

  def index

    @is_role_admin = Core.user.has_auth?(:manager)
    if @is_role_admin==true
      @p_group_id = nz(params[:p_group_id],0)
    else
      @p_group_id = nz(params[:p_group_id],Site.user_group.id)
    end
    params[:p_group_id]        = nz(params[:p_group_id],@p_group_id)

    #レイヤー登録一覧
    layer = Gis::Layer.new#.readable
    layer.search params
    layer.order params[:sort], "gis_layers.updated_at desc"
    @layers = layer.find(:all, :limit=>5, :include=>[:layers_managers], :select => "gis_layers.*, gis_layers_managers.group_id")

    #フォルダ登録一覧
    folder = Gis::Assortment.new#.readable
    folder.search params
    folder.order params[:sort], "updated_at desc"
    @folders = folder.find(:all, :limit=>5)

  end


end
