# encoding: utf-8
class System::Admin::GroupChangeDatesController < System::Controller::Admin::Base
  include System::Controller::Scaffold
  include System::Controller::Admin::Auth
  layout "admin/system/base"

  def initialize_scaffold
    Page.title = "組織変更日程登録"
    @is_role_admin = Core.user.has_auth?(:manager)
    return redirect_to "/_admin" unless @is_role_admin
  end

  def index
      item = System::GroupChangeDate.new#.readable
      item.page  params[:page], params[:limit]
      item.order params[:sort], "start_at desc"
      @items = item.find(:all)
      _index @items
  end

  def show
      @item = System::GroupChangeDate.new.find(params[:id])
      return authentication_error(404) unless @item.readable?

      _show @item
  end


  def new
      @item = System::GroupChangeDate.new
  end

  def edit
    @item = System::GroupChangeDate.where(:id => params[:id]).first
    return authentication_error(404) unless @item.readable?
  end

  def create
    @item = System::GroupChangeDate.new(params[:item])
    _create @item
  end

  def update
    @item = System::GroupChangeDate.new.find(params[:id])
    @item.attributes = params[:item]
    _update @item
  end

  def destroy
    @item = System::GroupChangeDate.where(:id => params[:id]).first
    _destroy @item
  end


end
