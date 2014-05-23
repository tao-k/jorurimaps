# encoding: utf-8
class System::Admin::UsersController < System::Controller::Admin::Base
  include System::Controller::Scaffold
  include System::Controller::Admin::Auth
  include System::Controller::Admin::UserCsv
  layout "admin/system/base"

  def initialize_scaffold
    return redirect_to(:action => :index) if params[:reset]

    Page.title = "ユーザー管理"
    params[:limit] = params[:limit].presence || '30'
    return authentication_error(403) unless Core.user.has_auth?(:manager)
  end

  def index
    init_params
    return authentication_error(403) unless @u_role

    item = System::User.new
    item.search params



    item.and :ldap, params[:ldap] if params[:ldap] && params[:ldap] != 'all'
    item.and :state, params[:state] if params[:state] && params[:state] != 'all'

    item.page   params[:page], nz(params[:limit], 30)


    item.order params[:sort], :code

    @items = item.find(:all)

    _index @items
  end

  def show
    init_params
    return authentication_error(403) unless @u_role
    @item = System::User.new.find(params[:id])

  end

  def get_start_at(params, item)
    @start_at = nil
    @end_at = nil
    if item.group_rels
      group_rel = item.group_rels[0]
      @start_at = group_rel.start_at if group_rel
      @end_at = group_rel.end_at if group_rel
    end
    @start_at = params[:ud][:start_at] if !params[:ud].blank? &&  !params[:ud][:start_at].blank?
    @end_at = params[:ud][:end_at] if !params[:ud].blank? &&  !params[:ud][:end_at].blank?
  end

  def new
    init_params
    return authentication_error(403) unless @u_role
    top_cond = "level_no=1"
    @top        = System::Group.find(:first,:conditions=>top_cond)
    @group_id = @top.id
    @item = System::User.new({
      :state      =>  'enabled',
      :ldap       =>  '0'
    })
    get_start_at(params, @item)
  end

  def create
    init_params
    return authentication_error(403) unless @u_role
    @item = System::User.new(params[:item])
    @item.id = params[:item]['id']

    get_start_at(params, @item)
    options={
      :location => system_users_path,
      :params=>params
    }
    ret = @item.save_with_rels(options)

    if ret[0]==true
      flash[:notice] = ret[1] || '登録処理が完了しました。'
      status = params[:_created_status] || :created
      options[:location] ||= url_for(:action => :index)
      respond_to do |format|
        format.html { redirect_to options[:location] }
        format.xml  { render :xml => @item.to_xml(:dasherize => false), :status => status, :location => url_for(:action => :index) }
      end
    else
      flash.now[:notice] = '登録処理に失敗しました。' + ' ' + ret[1]
      respond_to do |format|
        format.html { render :action => :new }
        format.xml  { render :xml => @item.errors, :status => :unprocessable_entity }
      end
    end
  end

  def edit
    init_params
    return authentication_error(403) unless @u_role
    @item = System::User.new.find(params[:id])
    get_start_at(params, @item)
  end

  def update
    init_params
    return authentication_error(403) unless @u_role

    @item = System::User.new.find(params[:id])
    @item.attributes = params[:item]
    get_start_at(params, @item)

    location = system_user_path(@item.id)
    options = {
      :success_redirect_uri=>location
      }
    _update(@item, options)
  end

  def destroy
    init_params
    return authentication_error(403) unless @u_role == true
    @item = System::User.find_by_id(params[:id])
    @item.state = 'disabled'
    _update(@item, {:notice => 'ユーザーを無効状態に更新しました。'})
  end

  def init_params
    @current_no = 1
    @u_role = Core.user.has_auth?(:manager)

    @limit = nz(params[:limit],30)

    search_condition

    Page.title = "ユーザー・グループ管理"
    if params[:action].index("csv").present?
      Page.title = "ユーザー・グループ CSV管理"
    end
    @ie = Gis.ie?(request)
  end

  def search_condition
    params[:limit]        = nz(params[:limit],@limit)

    qsa = ['limit', 's_keyword']
    @qs = qsa.delete_if{|x| nz(params[x],'')==''}.collect{|x| %Q(#{x}=#{params[x]})}.join('&')
  end

end
