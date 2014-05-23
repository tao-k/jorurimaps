# encoding: utf-8
class Gis::Admin::Maps::SocialUpdatesController < Gis::Controller::Admin::Base
  include System::Controller::Scaffold
  include System::Controller::Admin::Auth
  include System::Controller::Admin::GroupSelect
  layout "admin/gis/base_information"

  def initialize_scaffold
    @map = Gis::Map.where(:id => params[:map_id]).first
    return http_error(404) if @map.blank?
    Page.title = "#{@map.title} 更新情報管理"
    @is_role_admin = Core.user.has_auth?(:manager)
    @model_name = Misc::SocialUpdate.table_name
  end


  def index
      item = Misc::SocialUpdate.new#.readable
      item.and :map_id, @map.id
      item.page  params[:page], params[:limit]
      item.order params[:sort], "published_at desc"
      @items = item.find(:all)
      _index @items
  end

  def show
      @item = Misc::SocialUpdate.new.find(params[:id])
      return authentication_error(404) unless @item.readable?

      _show @item
  end


  def new
      @item = Misc::SocialUpdate.new({
        :map_id => @map.id,
        :web_state => "public",
        :published_at => Time.now,
        :inquiry_group_id => Core.user_group.id,
        :mail_to => Core.user_group.email
      })
      @item.set_tmp_id
  end

  def edit
    @item = Misc::SocialUpdate.where(:id => params[:id]).first
    return authentication_error(404) unless @item.readable?
    if @item.inquiry_group_id.blank?
      @item.inquiry_group_id = Core.user_group.id
      @item.mail_to = Core.user_group.email
    end
    @item.set_tmp_id
  end

  def create
    @item = Misc::SocialUpdate.new(params[:item])
    @item.map_id = @map.id
    _create @item do
      @item.cache_clear
    end
  end

  def update
      @item = Misc::SocialUpdate.new.find(params[:id])
      @item.attributes = params[:item]
      _update @item do
        @item.cache_clear
      end
  end

  def destroy
    @item = Misc::SocialUpdate.where(:id => params[:id]).first
    _destroy @item do
      cache_item = Misc::SocialUpdate.new
      cache_item.cache_clear
    end
  end


end
