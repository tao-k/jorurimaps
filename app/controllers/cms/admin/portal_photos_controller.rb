# encoding: utf-8
class Cms::Admin::PortalPhotosController < System::Controller::Admin::Base
  include System::Controller::Scaffold
  include System::Controller::Admin::Auth
  layout "admin/system/base"

  def initialize_scaffold
    Page.title = "ポータル写真管理"
    return authentication_error(403) unless Core.user.has_auth?(:manager)
  end

  def index
    item = Cms::PortalPhoto.new#.readable
    item.page  params[:page], params[:limit]
    item.order params[:sort], :sort_no
    @items = item.find(:all)
    _index @items
  end

  def show
    @item = Cms::PortalPhoto.new.find(params[:id])
    return authentication_error(403) unless @item.readable?

    _show @item
  end

  def new
    @item = Cms::PortalPhoto.new({
      :web_state => "public"
    })
  end

  def create
    @item = Cms::PortalPhoto.new
    if @item.save_with_file(params[:item],:create)
      @item.cache_clear
      return redirect_to url_for({:action => :index})
    else
      render :action => :new
    end
  end

  def update
    @item = Cms::PortalPhoto.new.find(params[:id])
    if @item.save_with_file(params[:item],:update)
      @item.cache_clear
      return redirect_to url_for({:action => :index})
    else
      render :action => :edit
    end
  end

  def destroy
    @item = Cms::PortalPhoto.new.find(params[:id])
    _destroy @item do
      @item.cache_clear
    end
  end


end
