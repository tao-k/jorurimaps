# encoding: utf-8
class System::Admin::RelatedLinksController < System::Controller::Admin::Base
  include System::Controller::Scaffold
  include System::Controller::Admin::Auth
  layout "admin/system/base"

  def initialize_scaffold
    Page.title = "関連リンク管理"
    @is_role_admin = Core.user.has_auth?(:manager)
    return authentication_error(403) unless Core.user.has_auth?(:manager)
  end

  def index
      item = System::RelatedLink.new#.readable
      item.page  params[:page], params[:limit]
      item.order params[:sort], "sort_no"
      @items = item.find(:all)
      _index @items
  end

  def show
      @item = System::RelatedLink.new.find(params[:id])
      return authentication_error(403) unless @item.readable?

      _show @item
  end


  def new
      @item = System::RelatedLink.new({
        :web_state => "public"
      })
  end

  def edit
      @item = System::RelatedLink.where(:id => params[:id]).first
      return authentication_error(403) unless @item.readable?
  end

  def create
      @item = System::RelatedLink.new(params[:item])
      _create @item do
        @item.cache_clear
      end
  end

  def update
      @item = System::RelatedLink.new.find(params[:id])
      @item.attributes = params[:item]
      _update @item do
        @item.cache_clear
      end
  end

  def destroy
      @item = System::RelatedLink.where(:id => params[:id]).first
      _destroy @item do
        cache_item = System::RelatedLink.new
        cache_item.cache_clear
      end
  end
end
