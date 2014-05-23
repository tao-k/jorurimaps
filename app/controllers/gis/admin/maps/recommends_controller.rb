# encoding: utf-8
class Gis::Admin::Maps::RecommendsController < System::Controller::Admin::Base
  include System::Controller::Scaffold
  include System::Controller::Admin::Auth
  layout "admin/gis/base"

  def initialize_scaffold
    @map = Gis::Map.where(:id => params[:map_id]).first
    return http_error(404) if @map.blank?
    Page.title = "#{@map.title} おすすめ検索設定"
    @is_role_admin = Core.user.has_auth?(:manager)
    @search_configs = Misc::SearchColumn.get_index_cache(@map)
  end

  def index
    item = Misc::PortalRecommend.new
    item.and :portal_id, @map.id
    item.page params[:page], params[:limit]
    item.order 'sort_no'
    @items = item.find(:all)

    _index @items
  end

  def show
    @item = Misc::PortalRecommend.find(:first, :conditions=>["id = ?", params[:id]])
    _show @item
  end

  def new
    @item = Misc::PortalRecommend.new({:web_state => "public", :portal_id=>@map.id})
  end

  def edit
    @item = Misc::PortalRecommend.find(params[:id])
  end

  def create
    @item = Misc::PortalRecommend.new
    if @item.save_with_file(params, :create)
      @item.cache_clear
      return redirect_to url_for({:action => :index})
    else
      render :action => :new
    end
  end


  def update
    @item = Misc::PortalRecommend.find(params[:id])
    if @item.save_with_file(params, :update)
      @item.cache_clear
      return redirect_to url_for({:action => :index})
    else
      render :action => :edit
    end
  end

  def destroy
    @item = Misc::PortalRecommend.find(params[:id])
    _destroy @item do
      @item.cache_clear
    end
  end

end
