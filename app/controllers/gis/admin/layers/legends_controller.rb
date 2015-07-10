# encoding: utf-8
class Gis::Admin::Layers::LegendsController < Gis::Controller::Admin::Base
  include System::Controller::Scaffold
  include System::Controller::Admin::Auth
  include System::Controller::Admin::UserSelect
  include Gis::Controller::Admin::Ajax
  layout :switch_layout

  def initialize_scaffold

    @is_role_admin = Core.user.has_auth?(:manager)
    if @is_role_admin==true
      @p_group_id = nz(params[:p_group_id],0)
    else
      @p_group_id = nz(params[:p_group_id],Site.user_group.id)
    end

    @layer = Gis::Layer.where(:id=>params[:layer_id]).first
    return http_error(404) if @layer.blank?
    Page.title = "#{@layer.title} レイヤー描画設定"
    @css = [
      "/_common/js/color_picker/spectrum.css"
    ]
    @js = [
      "/_common/js/color_picker/spectrum.js"
    ]
  end



  def index
    item = Gis::LayerDrawConfig.new
    #item.search params
    item.and :layer_id, @layer.id
    item.page  params[:page], params[:limit]
    item.order params[:sort], :updated_at
    @items = item.find(:all)
    @item = @items[0] if @items
    _index @items
  end

  def show
    @item = Gis::LayerDrawConfig.where(:id => params[:id], :layer_id => @layer.id).first
    return http_error(404) if @item.blank?
    _show @item
  end

  def new
    new_config = {
      :layer_id => @layer.id, :label_color => "rgb(0, 0, 0)",:point_color=>"rgb(0, 0, 0)",
      :line_color => "rgb(0, 0, 0)",:polygon_color=>"rgb(0, 0, 0)", :label_size => 8
      }
    @item = Gis::LayerDrawConfig.where(:layer_id => @layer.id).first || Gis::LayerDrawConfig.new(new_config)
    @show_config = Gis::LayerDataColumn.where(:id => params[:id]).first
    @item.geometry_type = @layer.geometry_type if @item.geometry_type.blank?

  end

  def edit
    @item = Gis::LayerDrawConfig.where(:layer_id => @layer.id).first
    @item.geometry_type = @layer.geometry_type if @item.geometry_type.blank?
    return http_error(404) if @item.blank?
    return authentication_error(403) unless @layer.editable?
  end

  def create
    @item = Gis::LayerDrawConfig.where(:layer_id => @layer.id).first || Gis::LayerDrawConfig.new({:layer_id => @layer.id})
    @item.attributes = params[:item]
    @item.layer_id = @layer.id
    if @item.save
      @item.update_mapfile
      flash[:notice] = "登録処理が完了しました。"
      return redirect_to url_for({:controller => "/gis/admin/layers", :action => :show, :id=>@layer.id})
    else
      return render :action => :new
    end
  end

  def update
    @item = Gis::LayerDrawConfig.where(:id => params[:id]).first
    return http_error(404) if @item.blank?
    @item.layer_id = @layer.id
    @item.attributes = params[:item]

    if @item.save
      @item.update_mapfile
      flash[:notice] = "編集処理が完了しました。"
      return redirect_to url_for({:controller => "/gis/admin/layers", :action => :show, :id=>@layer.id})
    else
      return render :action => :new
    end
  end


  def get_show_check(params)
    ret = []
    return nil if params[:show_check].blank?
    params[:show_check].each do |key, value|
      next unless value == "1"
      ret << key
    end
    return ret.join(",")
  end


  def destroy
    @item = Gis::LayerDrawConfig.where(:id => params[:id]).first
    _destroy @item
  end

private
  def switch_layout
    "admin/gis/base"
  end

end
