# encoding: utf-8
class Gis::Admin::Maps::RecognizersController< System::Controller::Admin::Base
  include System::Controller::Scaffold
  include System::Controller::Admin::Auth
  layout "admin/gis/base"

  def initialize_scaffold
    @map = Gis::Map.where(:id => params[:map_id]).first
    return http_error(404) if @map.blank?
    Page.title = "#{@map.title} 公開承認"
    @is_role_admin = Core.user.has_auth?(:manager)
    get_recognizers
  end

  def get_recognizers
    @selected_users = []
    if params[:users]
      params[:users].each do |user|
        rec_user = System::User.where(:id => user).first
        if rec_user
          next if rec_user.auth_no == 4
          @selected_users << rec_user
        end
      end
    else
      recognizers = Gis::MapsRecognizer.where(:portal_id=>@map.id)
      recognizers.each do |rec|
        rec_user = rec.user
        if rec_user
          next if rec_user.auth_no == 4
          @selected_users << rec_user
        end
      end unless recognizers.blank?
    end
    group_users = Site.user_group.users
    @group_users = []
    group_users.each do |gu|
      next if gu.auth_no == 4
      @group_users << gu if gu.id != Core.user.id
    end
  end


  def index
      item = Gis::MapsRecognizer.new#.readable
      item.and :portal_id, @map.id
      item.page  params[:page], params[:limit]
      item.order params[:sort], "recognized_at desc"
      @items = item.find(:all)
      _index @items
  end

  def show
      @item = Gis::MapsRecognizer.new.find(params[:id])
      return authentication_error(404) unless @item.readable?
      _show @item
  end


  def new
      @item = Gis::MapsRecognizer.new({
        :portal_id => @map.id
      })
  end

  def edit
    @item = Gis::MapsRecognizer.where(:rid => params[:id]).first
    return authentication_error(404) unless @item.readable?
  end

  def create
    @item = Gis::MapsRecognizer.new(params[:item])
    @item.portal_id = @map.id
    if @item.save_with_rels(params)
      return redirect_to url_for({:controller => '/gis/admin/maps', :action => :show, :id=>@map.id})
    else
      return render :action => :new
    end
  end

  def update
    @item = Gis::MapsRecognizer.where(:rid => params[:id]).first
    @item.attributes = params[:item]
    if @item.save_with_rels(params)
      return redirect_to url_for({:controller => '/gis/admin/maps', :action => :show, :id=>@map.id})
    else
      return render :action => :edit
    end
  end

  def destroy
    @item = Gis::MapsRecognizer.where(:rid => params[:id]).first
    #_destroy @item do
    #  #other_recognize = Gis::MapsRecognizer.count(:all, :conditions=>["portal_id = ?", @map.id])
    #end
    return redirect_to url_for({:controller => '/gis/admin/maps', :action => :show, :id=>@map.id})
  end

  def recognize
    @item = Gis::MapsRecognizer.where(:rid => params[:id]).first
    return http_error(404) if @item.blank?
    if @item.user_id == Site.user.id
      @item.recognized_at = Time.now
      @item.save(:validate=>false)

      other_recognize = Gis::MapsRecognizer.count(:all, :conditions=>["portal_id = ? and recognized_at IS NULL", @map.id])
      if other_recognize == 0
        @map.web_state = "recognized"
        @map.save(:validate=>false)
      end
      flash[:notice] = "公開承認を行いました。"
    else
      flash[:notice] = "公開承認に失敗しました。"
    end
    return redirect_to url_for({:controller => '/gis/admin/maps', :action => :show, :id=>@map.id})
  end

  def publish
    @map.web_state = "public"
    @map.save(:validate=>false)
    Gis::MapsRecognizer.destroy_all("portal_id = #{@map.id}")
    flash[:notice] = "マップを公開しました。"
    cache_item = Gis::Map.new
    cache_item.cache_clear
    return redirect_to url_for({:controller => '/gis/admin/maps', :action => :show, :id=>@map.id})
  end

end
