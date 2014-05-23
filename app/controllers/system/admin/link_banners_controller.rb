# encoding: utf-8
class System::Admin::LinkBannersController < System::Controller::Admin::Base
  include System::Controller::Scaffold
  include System::Controller::Admin::Auth
  layout "admin/gis/base"

  def initialize_scaffold
    @is_role_admin = Core.user.has_auth?(:manager)
    return authentication_error(403) unless @is_role_admin
    Page.title = "バナー広告管理"
  end


  def index
    item = System::LinkBanner.new#.readable
    item.page  params[:page], params[:limit]
    item.order params[:sort], :sort_no
    @items = item.find(:all)
    _index @items
  end

  def show
    @item = System::LinkBanner.new.find(params[:id])
    return authentication_error(403) unless @item.readable?

    _show @item
  end

  def new
    @item = System::LinkBanner.new({
      :web_state => "public"
    })
  end

  def create
    @item = System::LinkBanner.new
    if @item.save_with_file(params[:item],:create)
      @item.cache_clear
      return redirect_to url_for({:action => :index})
    else
      render :action => :new
    end
  end

  def update
    @item = System::LinkBanner.new.find(params[:id])
    if @item.save_with_file(params[:item],:update)
      @item.cache_clear
      return redirect_to url_for({:action => :index})
    else
      render :action => :edit
    end
  end

  def destroy
    @item = System::LinkBanner.new.find(params[:id])
    _destroy @item do
      @item.cache_clear
    end
  end


end
