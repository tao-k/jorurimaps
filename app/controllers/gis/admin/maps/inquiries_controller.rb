# encoding: utf-8
class Gis::Admin::Maps::InquiriesController < Gis::Controller::Admin::Base
  include System::Controller::Scaffold
  include System::Controller::Admin::Auth
  include System::Controller::Admin::GroupSelect
  layout "admin/gis/base"

  def initialize_scaffold
    @map = Gis::Map.where(:id => params[:map_id]).first
    return http_error(404) if @map.blank?
    Page.title = "#{@map.title} お問い合わせ先管理"
    @is_role_admin = Core.user.has_auth?(:manager)
  end


  def index
      item = Misc::Inquiry.new#.readable
      item.and :portal_id, @map.id
      item.page  params[:page], params[:limit]
      item.order params[:sort], "sort_no"
      @items = item.find(:all)
      _index @items
  end

  def show
      @item = Misc::Inquiry.new.find(params[:id])
      return authentication_error(404) unless @item.readable?

      _show @item
  end


  def new
      @item = Misc::Inquiry.new({
        :portal_id => @map.id,
        :inquiry_group_id => Core.user_group.id,
        :mail_to => Core.user_group.email
      })
  end

  def edit
    @item = Misc::Inquiry.where(:id => params[:id]).first
    return authentication_error(404) unless @item.readable?
  end

  def create
    @item = Misc::Inquiry.new(params[:item])
    @item.portal_id = @map.id
    _create @item
  end

  def update
    @item = Misc::Inquiry.new.find(params[:id])
    @item.attributes = params[:item]
    _update @item
  end

  def destroy
    @item = Misc::Inquiry.where(:id => params[:id]).first
    _destroy @item
  end


end
