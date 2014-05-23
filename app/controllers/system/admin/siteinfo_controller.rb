# encoding: utf-8
class System::Admin::SiteinfoController < System::Controller::Admin::Base
  include System::Controller::Scaffold
  layout "admin/system/base"

  def initialize_scaffold
    Page.title = "接続情報確認"
  end

  def index
    if addr = request.env['HTTP_CLIENT_IP']
      @client_ip = addr.to_s
    elsif addr = request.env['HTTP_X_CLUSTER_CLIENT_IP']
      @client_ip = addr.to_s
    elsif addr = request.env['HTTP_X_FORWARDED_FOR']
      @client_ip = (addr.split(',').grep(/\d\./).first || request.env['REMOTE_ADDR']).to_s.strip
    else
      @client_ip = request.env['REMOTE_ADDR']
    end
  end
end