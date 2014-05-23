# encoding: utf-8
class Gis::Public::PortalsController < Gis::Controller::Public::Base
  include Gis::Controller::Public::Map
  include System::Model::FileUtil
  #layout "admin/ud"
  layout :switch_layout

  def pre_dispatch
    @map = Gis::Map.where(:code=>params[:code], :web_state => "public").first
    return http_error(404) if @map.blank?

    Page.title = "#{@map.title}"
    @js = [
      "/javascripts/main.js",
      "http://maps.google.com/maps/api/js?gl=JP&sensor=false&language=ja&region=jp"
      ]
    @system_cities = System::City.find(:all, :order=>:sort_no)
  end

  def index
    return http_error(404) if @map.web_state != "public"
    Page.title = "#{@map.title}"
    case @map.portal_kind
    when 1
      portal1
    when 2
      portal2
    when 3
      portal_page
    when 4
      portal_page
    else
      #
    end
  end


  def portal_page
    @css = [
      "/_common/themes/gis/css/page/doc.css"
    ]

  end

private


  def switch_layout
    if @map.portal_kind == 2
      case params[:action].to_s
      when 'feature'
        "public/gis/template/plain"
      when 'portal1'
        "public/gis/template/map_base"
      when 'portal2'
        "public/gis/template/map_base"
      when 'layer'
        "public/gis/template/plain"
      when 'draw'
        "public/gis/template/plain"
      when 'base_layer'
        "public/gis/template/plain"
      when 'measure'
        "public/gis/template/plain"
      when 'feature_edit'
        "public/gis/template/plain"
      when 'legend'
        "public/gis/template/plain"
      when 'import_form'
        "public/gis/template/plain"
      when 'print'
        "public/gis/template/map_base"
      when 'export_form'
        "public/gis/template/plain"
      when 'slider'
        "public/gis/template/plain"
      else
        "public/gis/template/map_base"
      end
    elsif @map.portal_kind == 3
      "public/gis/template/doc"
    elsif @map.portal_kind == 4
      "public/gis/template/doc"
    elsif @map.portal_kind == 1
      case params[:action].to_s
      when 'feature'
        "public/gis/template/plain"
      when 'portal1'
        "public/gis/template/map_base"
      when 'portal2'
        "public/gis/template/map_base"
      when 'layer'
        "public/gis/template/plain"
      when 'draw'
        "public/gis/template/plain"
      when 'base_layer'
        "public/gis/template/plain"
      when 'measure'
        "public/gis/template/plain"
      when 'feature_edit'
        "public/gis/template/plain"
      when 'legend'
        "public/gis/template/plain"
      when 'import_form'
        "public/gis/template/plain"
      when 'print'
        "public/gis/template/map_base"
      when 'export_form'
        "public/gis/template/plain"
      else
        "public/gis/template/portal1"
      end
    else
      "public/gis/template/base"
    end
  end

end
