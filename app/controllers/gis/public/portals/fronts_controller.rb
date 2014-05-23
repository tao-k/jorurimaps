# encoding: utf-8
class Gis::Public::Portals::FrontsController< Gis::Controller::Public::Base
    layout "public/gis/template/portal1_1column"


  def pre_dispatch
    @map = Gis::Map.where(:code=>params[:code]).first
    return http_error(404) if @map.blank?

    Page.title = "#{@map.title}"
    @css = [
      '/_common/themes/gis/css/portal1/page/doc.css'
      ]
  end

  def about
    item = Misc::Inquiry.new#.readable
    item.and :portal_id, @map.id
    item.order params[:sort], "sort_no"
    @items = item.find(:all)
  end

  def sitemap
    #
  end
end
