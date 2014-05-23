# encoding: utf-8
class System::Admin::FrontsController < System::Controller::Admin::Base
  include System::Controller::Scaffold
  include System::Controller::Admin::Auth
  layout "admin/system/base"


  def initialize_scaffold
    return redirect_to(:action => :index) if params[:reset]

    Page.title = "総合地図提供システム"
    params[:limit] = params[:limit].presence || '30'
    return authentication_error(403) unless Core.user.has_auth?(:manager)
  end

  def index

    @messages = nil

    @maintenances = nil

  end
end
