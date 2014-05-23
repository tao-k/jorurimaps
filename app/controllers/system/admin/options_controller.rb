# encoding: utf-8
class System::Admin::OptionsController < System::Controller::Admin::Base
  include System::Controller::Scaffold
  include System::Controller::Admin::Auth
  layout "admin/system/base"


  def initialize_scaffold
    Page.title = "管理者設定"
    @is_role_admin = Core.user.has_auth?(:manager)
    return authentication_error(403) unless @is_role_admin
  end

  def index
    item = System::Option.new#.readable
    item.page  params[:page], params[:limit]
    item.order params[:sort], 'updated_at desc'
    @items = item.find(:all)
    _index @items
  end

  def show
    @item = System::Option.new.find(params[:id])
    return authentication_error(403) unless @is_role_admin

    _show @item
  end

  def new
    @item = System::Option.new
  end

  def create
    @item = System::Option.new(params[:item])
    _create @item
  end

  def update
    @item = System::Option.new.find(params[:id])
    @item.attributes = params[:item]
    _update @item
  end

  def destroy
    @item = System::Option.new.find(params[:id])
    _destroy @item
  end
end
