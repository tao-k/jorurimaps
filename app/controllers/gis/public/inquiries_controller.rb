# encoding: utf-8
class Gis::Public::InquiriesController < Gis::Controller::Public::Base
  include System::Model::FileUtil
  #layout "admin/ud"
  layout "public/gis/template/base"

  def pre_dispatch
    @js = [
      "/javascripts/main.js"
      ]
    @css = [
      "/_common/themes/gis/css/page/doc.css"
    ]
  end

  def index
    #
  end


end
