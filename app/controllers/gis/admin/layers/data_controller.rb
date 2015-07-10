# encoding: utf-8
class Gis::Admin::Layers::DataController < Gis::Controller::Admin::Base
  include System::Controller::Scaffold
  include System::Controller::Admin::Auth
  include System::Controller::Admin::UserSelect
  include Gis::Controller::Admin::Ajax
  layout :switch_layout

  def initialize_scaffold
    @js = [Gis.google_api_url]
    @css = [
      "/_common/themes/gis/css/map.css",
      "/_common/js/ExtJs/resources/css/ext-all.css",
      "/_common/js/ExtJs/resources/css/yourtheme.css"
    ]
    @is_role_admin = Core.user.has_auth?(:manager)
    if @is_role_admin==true
      @p_group_id = nz(params[:p_group_id],0)
    else
      @p_group_id = nz(params[:p_group_id],Site.user_group.id)
    end
    @model = Gis::LayerDatum

    @layer = Gis::Layer.where(:id=>params[:layer_id]).first
    return http_error(404) if @layer.blank?
    return authentication_error(403) unless @layer.is_data_layer?
    Page.title = "#{@layer.title} レイヤーデータ管理"
  end

   def get_photos
    @photos = Gis::LayerDataPhoto.find(:all, :conditions=>["layer_data_id = ?", params[:id]], :order => :sort_no)
  end

  def index
    item = Gis::LayerDatum.new
    item.search params
    item.and :layer_id, @layer.id
    item.page  params[:page], params[:limit]
    item.order params[:sort], "updated_at desc"
    @items = item.find(:all)
    _index @items
  end

  def get_paginate
    item = Gis::LayerDatum.new
    item.search params
    item.and :layer_id, @layer.id
    item.order params[:sort], "updated_at desc"
    @items = item.find(:all)

    @next = nil
    @prev = nil
    @current_page = 1
    @items.each_with_index{ |c_item, i|
      if c_item.rid == @item.rid
        @current_page += i
        if i  == 0
          @next = @items[i + 1]
        elsif i == @items.length - 1
          @prev = @items[i-1]
        else
          @next = @items[i + 1]
          @prev = @items[i-1]
        end
      end
    }
    @total_page = @items.length
  end

  def show
    @item = Gis::LayerDatum.where(:rid => params[:id], :layer_id => @layer.id).first
    return http_error(404) if @item.blank?
    get_photos
    get_paginate
    _show @item
  end

  def new
    default_icon = Gis::MapIcon.find(:first, :conditions=>["state = ?","public"], :order=>:sort_no)
    default_icon_id = 1
    default_icon_id = default_icon.id if !default_icon_id.blank?
    @item = Gis::LayerDatum.new({
      :state        => 'enabled',
      :layer_id     => @layer.id,
      :icon_id      => default_icon_id,
      :web_state => 'public',
      #:user_kind    => 2,
      #:is_internal  => 1,
      #:kind         => "file"
    })
    get_photos
  end

  def edit
    @item = Gis::LayerDatum.where(:rid => params[:id]).first
    @item.layer_id = @layer.id
    return http_error(404) if @item.blank?
    return authentication_error(403) unless @item.editable?
    get_photos
  end

  def create
    upload_file = params[:item][:upload]
    params[:item].delete(:upload)
    @item = Gis::LayerDatum.new(params[:item])
    @item.layer_id = @layer.id
    get_photos
    #@layer_file = Gis::LayerDatumFile.new
    _create @item do
      photo_item = Gis::LayerDataPhoto.new
      photo_item.manage_photos(@item, params, :create)
      Misc::SearchColumn.refresh_selects(@layer.id)
    end
  end

  def update
    @item = Gis::LayerDatum.where(:rid => params[:id]).first
    return http_error(404) if @item.blank?
    upload_file = params[:item][:upload]
    params[:item].delete(:upload)
    @item.layer_id = @layer.id
    @item.attributes = params[:item]
    #@layer_file = Gis::LayerDatumFile.where(:layer_id => params[:id]).first || Gis::LayerDatumFile.new
    _update @item do
      photo_item = Gis::LayerDataPhoto.new
      photo_item.manage_photos(@item, params, :update)
      Misc::SearchColumn.refresh_selects(@layer.id)
    end
  end

  def destroy
    @item = Gis::LayerDatum.where(:rid => params[:id]).first
    _destroy @item do
      Misc::SearchColumn.refresh_selects(@layer.id)
    end
  end

  def photo_sort
    @item = Gis::LayerDatum.where(:rid => params[:id]).first
    @items = Gis::LayerDataPhoto.find(:all, :conditions=>["layer_data_id = ?",@item.rid])
    par_item = params[:photo]
    unless par_item.blank?
      @items.each do |item|
        if par_item[:_sort_no].blank?
        else
          item.sort_no = par_item[:_sort_no]["#{item.id}"]
          item.save(:validate => false)
        end
      end unless @items.blank?
    end
    return redirect_to url_for({:controller=> "gis/admin/layers/data", :action=>:show,  :id=>params[:id]})
  end



  def csv_put
    if params[:do] == "csv"
      full_uri = Core.full_uri
      full_uri = full_uri.chop if full_uri.ends_with?('/')
      options = {:url=>full_uri }
      ret = Gis::Script::Tool.export_csv(params, @layer,options)
      if ret == "NG"
        flash[:notice] = "CSV出力時にエラーが発生しました。"
        return redirect_to url_for({:action => :csv_put})
      elsif ret == "NODATA"
        flash[:notice] = "データが登録されていません。"
        return redirect_to url_for({:action => :csv_put})
      else
        #IE判定
        user_agent = request.headers['HTTP_USER_AGENT']
        chk = user_agent.index("MSIE")
        chk = user_agent.index("Trident") if chk.blank?
        time_str = Time.now.strftime("%Y年%m月%d日_%H時%M分")
        item_filename = "#{@layer.title}_登録データ一覧_#{time_str}.csv"
        if chk.blank?
          item_filename = item_filename
        else
          item_filename = item_filename.tosjis
        end
        send_data(ret, :type => 'text/csv; charset=Shift_JIS', :filename => item_filename)
        return
      end
    end
  end

  def csv_up
    if params[:do] == "up" && params[:item] && params[:item][:file]
      invalid_filetype = false
      if params[:item][:file].original_filename =~ /#{params[:item][:kind]}/
        if params[:item][:kind] == "csv"
          ret = Gis::Script::Tool.import_form_csv(params, @layer)
        else
          ret = Gis::Script::Tool.import_photos_from_csv(params, @layer)
        end
      else
        invalid_filetype = true
        ret = {:result => false}
      end
      if ret[:result]
        Misc::SearchColumn.refresh_selects(@layer.id)
        flash[:notice]="#{ret[:count]}件のデータを登録しました。"
        return redirect_to url_for({:action=>:index})
      else
        if invalid_filetype
          flash[:notice]="選択された種別と、実際のファイル拡張子が異なっています。"
        else
          flash[:notice]="CSVの解析に失敗しました。"
        end
        return redirect_to url_for({:action=>:csv_up})
      end
    end
  end


private
  def switch_layout
    "admin/gis/base"
  end

end
