# encoding: utf-8
class Gis::Admin::Maps::RelatedLinksController < Gis::Controller::Admin::Base
  include System::Controller::Scaffold
  include System::Controller::Admin::Auth
  layout "admin/gis/base"

  def initialize_scaffold
    @map = Gis::Map.where(:id => params[:map_id]).first
    return http_error(404) if @map.blank?
    Page.title = "#{@map.title} 関連リンク設定"
    @is_role_admin = Core.user.has_auth?(:manager)
  end


  def index
      item = Misc::PortalLink.new#.readable
      item.and :portal_id, @map.id
      item.page  params[:page], params[:limit]
      item.order params[:sort], "sort_no"
      @items = item.find(:all)
      _index @items
  end

  def show
      @item = Misc::PortalLink.new.find(params[:id])
      return authentication_error(403) unless @item.readable?

      _show @item
  end


  def new
      @item = Misc::PortalLink.new({
        :web_state => "public",
        :portal_id => @map.id
      })
  end

  def edit
      @item = Misc::PortalLink.where(:id => params[:id]).first
      return authentication_error(403) unless @item.readable?
  end

  def create
      @item = Misc::PortalLink.new(params[:item])
      @item.portal_id = @map.id
      _create @item do
        @item.cache_clear
      end
  end

  def update
      @item = Misc::PortalLink.new.find(params[:id])
      @item.attributes = params[:item]
      _update @item do
        @item.cache_clear
      end
  end

  def destroy
    @item = Misc::PortalLink.where(:id => params[:id]).first
    @item.cache_clear
    _destroy @item do
      @item.cache_clear
    end
  end

end
