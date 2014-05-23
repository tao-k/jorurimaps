# encoding: utf-8
class Gis::Admin::Maps::PortalPhotosController < System::Controller::Admin::Base
  include System::Controller::Scaffold
  include System::Controller::Admin::Auth
  layout "admin/gis/base"

  def initialize_scaffold
    @map = Gis::Map.where(:id => params[:map_id]).first
    return http_error(404) if @map.blank?
    Page.title = "#{@map.title} ポータル写真設定"
    @is_role_admin = Core.user.has_auth?(:manager)
  end


  def index
    item = Misc::PortalPhoto.new#.readable
    item.and :portal_id, @map.id
    item.page  params[:page], params[:limit]
    item.order params[:sort], :sort_no
    @items = item.find(:all)
    _index @items
  end

  def show
    @item = Misc::PortalPhoto.new.find(params[:id])
    return authentication_error(403) unless @item.readable?

    _show @item
  end

  def new
    @item = Misc::PortalPhoto.new({
      :web_state => "public",
      :portal_id => @map.id
    })
  end

  def create
    @item = Misc::PortalPhoto.new
    if @item.save_with_file(params[:item],:create)
      return redirect_to url_for({:action => :index})
    else
      render :action => :new
    end
  end

  def update
    @item = Misc::PortalPhoto.new.find(params[:id])
    if @item.save_with_file(params[:item],:update)
      return redirect_to url_for({:action => :index})
    else
      render :action => :edit
    end
  end

  def destroy
    @item = Misc::PortalPhoto.new.find(params[:id])
    _destroy @item
  end


end
