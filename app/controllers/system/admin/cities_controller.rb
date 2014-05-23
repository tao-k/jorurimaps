# encoding: utf-8
class System::Admin::CitiesController < System::Controller::Admin::Base
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
    item = System::City.new
    item.page params[:page], params[:limit]
    item.order "system_prefs.sort_no, system_cities.sort_no"
    @items = item.find(:all, :include => [:pref])
    _index @items
  end

  def show
    @item = System::City.find(params[:id])

    _show @item
  end

  def new
    @item = System::City.new
  end

  def create
    @item = System::City.new(params[:item])

    _create @item
  end

  def edit
    @item = System::City.find(params[:id])
  end

  def update
    @item = System::City.new.find(params[:id])
    @item.attributes = params[:item]

    _update @item
  end

  def destroy
    @item = System::City.new.find(params[:id])

    _destroy @item
  end
end