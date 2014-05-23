# encoding: utf-8
class Gis::Admin::Layers::ColumnsController < Gis::Controller::Admin::Base
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
    @model = Gis::LayerDataColumn

    @layer = Gis::Layer.where(:id=>params[:layer_id]).first
    return http_error(404) if @layer.blank?
    return authentication_error(403) unless @layer.is_data_layer?
    Page.title = "#{@layer.title} レイヤー項目名管理"
    #return authentication_error(403) unless @layer.is_editable?
  end



  def index
    item = Gis::LayerDataColumn.new
    item.and :layer_id, @layer.id
    item.page  params[:page], params[:limit]
    item.order params[:sort], :updated_at
    @items = item.find(:all)
    @item = @items[0] if @items
    _index @items
  end

  def show
    @item = Gis::LayerDataColumn.where(:id => params[:id], :layer_id => @layer.id).first
    return http_error(404) if @item.blank?
    _show @item
  end

  def new
    return redirect_to url_for({:action => :index}) unless @layer.column_config.blank?
    @item = Gis::LayerDataColumn.new({
      :layer_id     => @layer.id
    })
  end

  def edit
    @item = Gis::LayerDataColumn.where(:id => params[:id]).first
    @item.layer_id = @layer.id
    return http_error(404) if @item.blank?
    return authentication_error(403) unless @layer.editable?
  end

  def create
    return redirect_to url_for({:action => :index}) unless @layer.column_config.blank?
    @item = Gis::LayerDataColumn.new(params[:item])
    @item.layer_id = @layer.id
    @item.show_fld = get_show_check(params)
    _create @item
  end

  def update
    @item = Gis::LayerDataColumn.where(:id => params[:id]).first
    return http_error(404) if @item.blank?
    @item.layer_id = @layer.id
    @item.attributes = params[:item]
    @item.show_fld = get_show_check(params)
    _update @item
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
    @item = Gis::LayerDataColumn.where(:id => params[:id]).first
    _destroy @item
  end

private
  def switch_layout
    "admin/gis/base"
  end

end
