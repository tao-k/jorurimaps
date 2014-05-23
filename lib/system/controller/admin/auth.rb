# encoding: utf-8
module System::Controller::Admin::Auth
  extend ActiveSupport::Concern


  included do
    before_filter :authenticate_role_priv
  end

  protected

  def authenticate_role_priv
    #if Core.user.present? && Core.user.has_auth?(:controller => params[:controller], :action => params[:action])
    if Core.user.present?
      return true
    else
      return authentication_error
    end
  end
end