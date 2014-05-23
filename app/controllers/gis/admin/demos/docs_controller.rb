# encoding: utf-8
class Gis::Admin::Demos::DocsController < Gis::Controller::Admin::Base
    layout "admin/gis/template/portal1_1column"

  def pre_dispatch
    @map = Gis::Map.where(:code=>params[:demo_id]).first
    return http_error(404) if @map.blank?

    Page.title = "#{@map.title}"
    @content_class = "docPage"
    @css = [
      '/_common/themes/gis/css/portal1/page/doc.css'
      ]
    @limit = params[:limit] || 10
  end


  def index
    item = Misc::SocialUpdate.new#.readable
    item.and :web_state, "public"
    item.and :map_id, @map.id
    item.and "sql", %Q(published_at <= '#{Time.now.strftime("%Y-%m-%d %H:%M")}')
    item.page  params[:page], @limit
    item.order params[:sort], "published_at desc"
    @items = item.find(:all)
  end

  def show
    @item = Misc::SocialUpdate.where(:id=>params[:id]).first
    return http_error(404) if @item.blank?
  end


end
