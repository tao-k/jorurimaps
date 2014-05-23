# encoding: utf-8
class System::Admin::SocialUpdatesController < System::Controller::Admin::Base
  include System::Controller::Scaffold
  include System::Controller::Admin::Auth
  include System::Controller::Admin::GroupSelect
  layout "admin/system/base"

  def initialize_scaffold
    Page.title = "更新情報管理"
    @is_role_admin = Core.user.has_auth?(:manager)
    @model_name = System::SocialUpdate.table_name
    return authentication_error(403) unless @is_role_admin
  end

  def index
      item = System::SocialUpdate.new#.readable
      item.page  params[:page], params[:limit]
      item.order params[:sort], "published_at desc"
      @items = item.find(:all)
      _index @items
  end

  def show
      @item = System::SocialUpdate.new.find(params[:id])
      return authentication_error(404) unless @item.readable?

      _show @item
  end


  def new
      @item = System::SocialUpdate.new({
        :is_tweet => 0,
        :web_state => "public",
        :published_at => Time.now,
        :inquiry_group_id => Core.user_group.id,
        :mail_to => Core.user_group.email
      })
      @item.set_tmp_id
  end

  def edit
    @item = System::SocialUpdate.where(:id => params[:id]).first
    return authentication_error(404) unless @item.readable?
    if @item.inquiry_group_id.blank?
      @item.inquiry_group_id = Core.user_group.id
      @item.mail_to = Core.user_group.email
    end
    @item.set_tmp_id
  end

  def create
      @item = System::SocialUpdate.new(params[:item])
      _create @item do
        @item.cache_clear
      end
  end

  def update
      @item = System::SocialUpdate.new.find(params[:id])
      @item.attributes = params[:item]
      _update @item do
        @item.cache_clear
      end
  end

  def destroy
      @item = System::SocialUpdate.where(:id => params[:id]).first
      _destroy @item do
        cache_item = System::SocialUpdate.new
        cache_item.cache_clear
      end
  end

end
