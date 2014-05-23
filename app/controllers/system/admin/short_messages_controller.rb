# encoding: utf-8
class System::Admin::ShortMessagesController < System::Controller::Admin::Base
  include System::Controller::Scaffold
  include System::Controller::Admin::Auth
  layout "admin/system/base"

  def initialize_scaffold
    Page.title = "一行メッセージ管理"
    @is_role_admin = Core.user.has_auth?(:manager)
    return authentication_error(403) unless @is_role_admin

  end

  def index
      item = System::ShortMessage.new#.readable
      item.page  params[:page], params[:limit]
      item.order params[:sort], "sort_no"
      @items = item.find(:all)
      _index @items
  end

  def show
      @item = System::ShortMessage.new.find(params[:id])
      return authentication_error(403) unless @item.readable?

      _show @item
  end


  def new
      @item = System::ShortMessage.new
      @item.sort_no = @item.next_sort_no
  end

  def edit
      @item = System::ShortMessage.where(:id => params[:id]).first
      return authentication_error(403) unless @item.readable?
  end

  def create
      @item = System::ShortMessage.new(params[:item])
      #@item.inner_text!
      _create @item do
        @item.cache_clear
      end
  end

  def update
      @item = System::ShortMessage.new.find(params[:id])
      @item.attributes = params[:item]
      #@item.inner_text!
      _update @item do
        @item.cache_clear
      end
  end

  def destroy
      @item = System::ShortMessage.where(:id => params[:id]).first
      _destroy @item do
        cache_item = System::ShortMessage.new
        cache_item.cache_clear
      end
  end
end
