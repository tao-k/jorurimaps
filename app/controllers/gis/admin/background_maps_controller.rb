# encoding: utf-8
class Gis::Admin::BackgroundMapsController < Gis::Controller::Admin::Base
  include System::Controller::Scaffold
  include System::Controller::Admin::Auth
  layout "admin/gis/base"


  def initialize_scaffold
    Page.title = "背景地図管理"
    return authentication_error(403) unless Core.user.has_auth?(:manager)
  end

  def index
    item = Gis::BackgroundMap.new#.readable
    item.page  params[:page], params[:limit]
    item.order params[:sort], :sort_no
    @items = item.find(:all)
    _index @items
  end

  def show
    @item = Gis::BackgroundMap.new.find(params[:id])
    _show @item
  end

  def new
    @item = Gis::BackgroundMap.new({
      :state        => 'public'
    })
    @item.sort_no = @item.get_max_sort_no
  end

  def create
    @item = Gis::BackgroundMap.new(params[:item])
    _create @item do
      @item.cache_clear
    end
  end

  def update
    @item = Gis::BackgroundMap.new.find(params[:id])
    @item.attributes = params[:item]
    _update @item do
      @item.cache_clear
    end
  end

  def destroy
    @item = Gis::BackgroundMap.new.find(params[:id])
    _destroy @item do
      @item.cache_clear
    end
  end
end
