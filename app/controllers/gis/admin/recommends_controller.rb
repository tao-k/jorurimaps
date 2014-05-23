# encoding: utf-8
class Gis::Admin::RecommendsController< System::Controller::Admin::Base
  include System::Controller::Scaffold
  include System::Controller::Admin::Auth
  layout "admin/gis/base"

  def initialize_scaffold
    Page.title = "おすすめマップ設定"
    @is_role_admin = Core.user.has_auth?(:manager)
    return authentication_error(403) unless @is_role_admin

  end



  def index
    return redirect_to url_for({:controller=>"gis/admin/maps",:action=>:index})
  end

  def show
    return redirect_to url_for({:controller=>"gis/admin/maps",:action=>:index})
  end


  def new
    item = Gis::Map.new
    item.order "sort_no"
    @items = item.find(:all)
  end

  def create
    current_recommends = Gis::Map.where(:is_recommend => 1)
    current_recommends.each do |c_item|
      c_item.update_column("is_recommend" , 0)
    end

    set_recommend_ids = params[:ids]
    item = Gis::Map.new
    item.and :id, set_recommend_ids
    @items = item.find(:all)

    @items.each do |s_item|
      s_item.update_column("is_recommend" , 1)
    end

    item = Gis::Map.new
    item.cache_clear_list
    flash[:notice] = "おすすめマップの設定を変更しました。"

    return redirect_to url_for({:controller=>"gis/admin/recommends",:action=>:new})

  end

  def edit
    return redirect_to url_for({:controller=>"gis/admin/maps",:action=>:index})
  end


  def update
    return redirect_to url_for({:controller=>"gis/admin/maps",:action=>:index})
  end

  def destroy
    #@item = Gis::MapsRecognizer.where(:rid => params[:id]).first
    #_destroy @item do
    #  #other_recognize = Gis::MapsRecognizer.count(:all, :conditions=>["portal_id = ?", @map.id])
    #end
    return redirect_to url_for({:controller=>"gis/admin/maps",:action=>:show, :id=>@map.id})
  end



end
