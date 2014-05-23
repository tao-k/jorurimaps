# encoding: utf-8
class Gis::Public::DocsController < Gis::Controller::Public::Base
  include System::Model::FileUtil
  #layout "admin/ud"
  layout "public/gis/template/doc"

  def pre_dispatch
    @js = [
      "/javascripts/main.js"
      ]
    @css = [
      "/_common/themes/gis/css/page/doc.css"
    ]
  end

  def index
    item = System::SocialUpdate.new#.readable
    item.and :web_state, "public"
    item.and "sql", %Q(published_at <= '#{Time.now.strftime("%Y-%m-%d %H:%M")}')
    item.page  params[:page], params[:limit]
    item.order params[:sort], "published_at desc"
    @items = item.find(:all)
  end

  def show
    @item = System::SocialUpdate.where(:name=>params[:name]).first
    return http_error(404) if @item.blank?
  end

  def redirect
    @item = System::SocialUpdate.where(:id=>params[:id]).first
    return http_error(404) if @item.blank?
    return redirect_to "/doc/#{@item.name}/"
  end


end
