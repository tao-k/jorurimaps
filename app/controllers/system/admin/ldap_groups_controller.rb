# encoding: utf-8
class System::Admin::LdapGroupsController < System::Controller::Admin::Base
  include System::Controller::Scaffold
  layout "admin/system/base"

  def initialize_scaffold
    Page.title = "LDAP情報管理"
    @current_no = 2

    return authentication_error(403) unless Core.user.has_auth?(:manager)
    return render(:text=> "LDAPサーバに接続できません。", :layout => true) unless Core.ldap.connection
    @role_admin = @admin = System::User.is_admin?

    return authentication_error(403) unless Core.user.has_auth?(:manager)

    if params[:parent] == '0'
      @parent  = nil
      @parents = []
    else
      @parent  = Core.ldap.group.find(params[:parent])
      @parents = @parent.parents
    end
  end

  def index
    if !@parent
      @groups = Core.ldap.group.children
      @users  = []
    else
      @groups = @parent.children
      @users  = @parent.users
    end
  end
end
