# encoding: utf-8
class System::Admin::CountiesController < System::Controller::Admin::Base
  include System::Controller::Scaffold
  include System::Controller::Admin::Auth
  layout "admin/system/base"

  def initialize_scaffold
    return redirect_to(:action => :index) if params[:reset]

    Page.title = "エリア設定"
    @js = ["/javascripts/main.js","http://maps.google.com/maps/api/js?sensor=false"]
    params[:limit] = params[:limit].presence || '30'
    return authentication_error(403) unless Core.user.has_auth?(:manager)
  end

  def index
    item = System::County.new
    item.page params[:page], params[:limit]
    item.order :sort_no
    @items = item.find(:all, :include => [:pref])

    _index @items
  end

  def show
    @item = System::County.find(params[:id])

    _show @item
  end

  def new
    @item = System::County.new
  end

  def create
    @item = System::County.new(params[:item])

    _create @item
  end

  def edit
    @item = System::County.find(params[:id])
  end

  def update
    @item = System::County.new.find(params[:id])
    @item.attributes = params[:item]

    _update @item
  end

  def destroy
    @item = System::County.new.find(params[:id])

    _destroy @item
  end
end
