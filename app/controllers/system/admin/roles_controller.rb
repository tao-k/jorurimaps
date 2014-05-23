# encoding: utf-8
class System::Admin::RolesController< System::Controller::Admin::Base
  include System::Controller::Scaffold
  include System::Controller::Admin::Auth
  include System::Controller::Admin::UserSelect
  layout "admin/system/base"

  def initialize_scaffold
    @css = %w(/layout/admin/style.css)
    index_path = system_roles_path
    return redirect_to(index_path) if params[:reset]
    return authentication_error(403) unless Core.user.has_auth?(:manager)

  end

  def index
    init_params
    return authentication_error(403) unless @is_admin || @is_dev
    item = System::Role.new
    item.page  params[:page], params[:limit]
    item.search params
    item.and 'priv_name', '!=','developer'
    @items = item.find(:all,
      :include => [:role_name, :group, :user],
      :order => 'system_role_names.sort_no, priv_name, idx, class_id,system_users.code, system_groups.sort_no, system_groups.code')
  end

  def show
    init_params
    return authentication_error(403) unless @is_admin || @is_dev
    @item = System::Role.find(params[:id])
  end

  def new
    init_params
    return authentication_error(403) unless @is_admin || @is_dev
    @item = System::Role.new({
      :class_id => '1',
      :priv => '1'})
  end

  def create
    init_params
    return authentication_error(403) unless @is_admin || @is_dev
    conv_uidraw_to_uid
    @item = System::Role.new(params[:item])
    location = "#{url_for({:action => :index})}?#{@qs}"
    options = {
      :success_redirect_uri=>location
      }
    _create(@item,options)
  end

  def edit
    init_params
    return authentication_error(403) unless @is_admin || @is_dev
    @item = System::Role.find_by_id(params[:id])
  end

  def update
    init_params
    return authentication_error(403) unless @is_admin || @is_dev
    conv_uidraw_to_uid
    @item = System::Role.new.find(params[:id])
    @item.attributes = params[:item]
    location = "#{url_for({:action => :show})}?#{@qs}"
    options = {
      :success_redirect_uri=>location
      }
    _update(@item,options)
  end

  def conv_uidraw_to_uid()
    params[:item]['uid'] = ( params[:item]['class_id'] == '1' ? params[:item]['uid_raw'] : params[:item]['gid_raw']) if nz(params[:item]['class_id'],'') != ''
    params[:item]['group_id'] = ( params[:item]['class_id'] == '1' ? params[:item]['gid_raw'] : '') if nz(params[:item]['class_id'],'') != ''
    params[:item].delete 'uid_raw'
    params[:item].delete 'gid_raw'
  end

  def destroy
    init_params
    return authentication_error(403) unless @is_admin || @is_dev
    @item = System::Role.new.find(params[:id])
    options = {
      :success_redirect_uri=>"#{url_for({:action => :index})}?#{@qs}"
      }
    _destroy(@item,options)
  end

  def init_params
    @is_dev = System::Role.is_dev?
    @is_admin = System::Role.is_admin?
    @role_id = nz(params[:role_id],0)
    @priv_id = nz(params[:priv_id],0)

    Page.title = "権限設定"
    @js = ["/_common/js/gw.js"]
    search_condition
  end

  def search_condition
    params[:role_id]    = nz(params[:role_id], @role_id)

    qsa = ['role_id' , 'priv_id' , 'role' , 'priv_user']
    @qs = qsa.delete_if{|x| nz(params[x],'')==''}.collect{|x| %Q(#{x}=#{params[x]})}.join('&')
  end


  def getajax
    role_id = params['role_id']
    @items = Array.new
    if role_id.blank? || role_id == ""
      @items = {:errors=>'空欄です'}
    else
      _items = System::RoleNamePriv.get_priv_items(role_id)

      _items.each_with_index do |_item, i|
        @items << [1, "",  ""] if i == 0
        @items << [1, _item.priv_id,  Gis.trim(_item.priv.display_name)]
      end
    end
    _show @items
  end

end
