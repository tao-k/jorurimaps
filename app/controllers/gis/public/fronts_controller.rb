# encoding: utf-8
class Gis::Public::FrontsController < Gis::Controller::Public::Base
  include System::Model::FileUtil
  #layout "admin/ud"
  #layout "public/gis/template/base"
  layout :switch_layout
  def pre_dispatch
    @js = [
      "/javascripts/main.js"
      ]

    @action = params[:action]
  end

  def index
    @css = [
      "/_common/themes/gis/css/page/top.css"
    ]
    @category = "top"

    map = Gis::Map.new
    map.and "sql", "portal_kind != 5"
    map.and :web_state , "public"
    map.page  params[:page], 10
    map.order params[:sort], " (is_recommend is null),is_recommend desc,updated_at desc,updated_at desc,sort_no"
    @maps = map.find(:all)

  end

  def about
    @css = [
      "/_common/themes/gis/css/page/doc.css"
    ]
  end

  def howto
    @css = [
      "/_common/themes/gis/css/page/doc.css"
    ]
  end

  def use
    @css = [
      "/_common/themes/gis/css/page/doc.css"
    ]
  end

  def sitemap
    @css = [
      "/_common/themes/gis/css/page/doc.css"
    ]
  end

  def help
    @css = [
      "/_common/themes/gis/css/page/doc.css"
    ]
  end

private


  def switch_layout
    case params[:action]
    when "help"
      "public/gis/template/help"
    else
      "public/gis/template/base"
    end
  end

end
