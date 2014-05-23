# encoding: utf-8
class System::Admin::PrivsController < System::Controller::Admin::Base
  include System::Controller::Scaffold
  include System::Controller::Admin::Auth
  layout "admin/system/base"

  def initialize_scaffold
    return redirect_to(:action => :index) if params[:reset]

    Page.title = "権限管理"
    params[:limit] = params[:limit].presence || '30'
    return authentication_error(403) unless Core.user.has_auth?(:manager)
  end

  def index
    item = System::Priv.new
    item.search params
    item.order 'sort_no, id'
    item.page params[:page], params[:limit]
    @items = item.find(:all)
  end

  def show
    @item = System::Priv.find(params[:id])

    _show @item
  end

  def new
    @item = System::Priv.new
  end

  def create
    @item = System::Priv.new(params[:item])

    _create @item
  end

  def edit
    @item = System::Priv.find(params[:id])
  end

  def update
    @item = System::Priv.find(params[:id])
    @item.attributes = params[:item]

    _update @item
  end

  def destroy
    @item = System::Priv.find(params[:id])

    _destroy @item
  end

  def edit_order
    @items = System::Priv.find(:all, :order => 'sort_no, id')
  end

  def update_order
    return http_error(404) if params[:sort_no].blank?

    @items = System::Priv.find(:all, :order => 'sort_no, id')

    params[:sort_no].each do |id, sort_no|
      if item = @items.find{|item| item.id.to_s == id}
        item.sort_no = sort_no
      end
    end

    _update_items @items, :error_action => :edit_order
  end
end
