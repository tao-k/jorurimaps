# encoding: utf-8
class Gis::Admin::MapIconsController < Gis::Controller::Admin::Base
  include System::Controller::Scaffold
  include System::Controller::Admin::Auth
  layout "admin/gis/base"

  def initialize_scaffold
    Page.title = "マップアイコン管理"
  end

  def index
    item = Gis::MapIcon.new#.readable
    item.page  params[:page], params[:limit]
    item.order params[:sort], :sort_no
    @items = item.find(:all)
    _index @items
  end

  def show
    @item = Gis::MapIcon.new.find(params[:id])
    _show @item
  end

  def new
    @item = Gis::MapIcon.new({
      :state => "public",
      :position_offset => 1
    })
    @item.sort_no = @item.get_max_sort_no
  end

  def create
    @item = Gis::MapIcon.new
    if @item.save_with_file(params[:item],:create)
      return redirect_to url_for({:action => :index})
    else
      render :action => :new
    end
  end

  def update
    @item = Gis::MapIcon.new.find(params[:id])
    if @item.save_with_file(params[:item],:update)
      return redirect_to url_for({:action => :index})
    else
      render :action => :edit
    end
  end

  def destroy
    @item = Gis::MapIcon.new.find(params[:id])
    _destroy @item
  end

  def icon
    @item = Gis::MapIcon.new.find(params[:id])
  end

end
