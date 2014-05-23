# encoding: utf-8
module Gis::Controller::Admin::Ajax

  def get_center
    return http_error(404) if params[:area_code].blank?
    @item = System::City.find(:first, :conditions=>["rid = ? ", params[:area_code]])
    ret = "NG"
    ret = "#{@item.lat},#{@item.lng}" if !@item.lat.blank? && !@item.lng.blank? unless @item.blank?
    render :text => ret
  end

end