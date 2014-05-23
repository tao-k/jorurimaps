# encoding: utf-8
class Gis::Public::CategoriesController < Gis::Controller::Public::Base
  include System::Model::FileUtil
  include Gis::PortalHelper
  #layout "admin/ud"
  layout "public/gis/template/base"

  def pre_dispatch
    @category = params[:code]
    @js = [
      "/javascripts/main.js"
      ]

    @css = [
      "/_common/themes/gis/css/page/bunya.css"
    ]
    @content_class = "bunya-#{@category}"
    @class_title = class_title(@category)
  end

  def index
    #
  end

  def show
    map = Gis::Map.new
    map.and "sql", "portal_kind != 5"
    condition = Condition.new()
    condition.and do |cond|
      cond.or :parent_category_id , params[:code]
      cond.or :parent_category_id_1 , params[:code]
      cond.or :parent_category_id_2 , params[:code]
    end
    map.and condition
    map.and :web_state , "public"
    map.page  params[:page], 10
    map.order params[:sort], " (is_recommend is null),is_recommend desc,updated_at desc,sort_no"
    @maps = map.find(:all)

    @feeds = Misc::FeedItem.order("published_at desc").has_genre(@class_title).limit(10)
  end


end
