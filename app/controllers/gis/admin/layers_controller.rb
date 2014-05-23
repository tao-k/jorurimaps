# encoding: utf-8
class Gis::Admin::LayersController < Gis::Controller::Admin::Base
  include System::Controller::Scaffold
  include System::Controller::Admin::Auth
  include System::Controller::Admin::UserSelect
  layout :switch_layout

  def initialize_scaffold
    Page.title = "レイヤー管理"
    @is_role_admin = Core.user.has_auth?(:manager)
    if @is_role_admin==true
      @p_group_id = nz(params[:p_group_id],0)
    else
      @p_group_id = nz(params[:p_group_id],1)
    end
    @model = Gis::Layer
    search_condition
  end

  def search_condition
    params[:limit]             = nz(params[:limit],@limit)
    params[:p_group_id]        = nz(params[:p_group_id],@p_group_id)
    qsa = ['limit', 's_keyword','p_state','p_kind','p_cat','p_type','p_group_id','p_connect']
    @qs = qsa.delete_if{|x| nz(params[x],'')==''}.collect{|x| %Q(#{x}=#{params[x]})}.join('&')
  end

  def index
    item = Gis::Layer.new#.readable
    item.search params
    item.page  params[:page], params[:limit]
    item.order params[:sort], "gis_layers.updated_at desc"
    @items = item.find(:all, :include=>[:layers_managers], :select => "gis_layers.*, gis_layers_managers.group_id")
    _index @items
  end

  def side_menu
    if @is_role_admin==true
      params[:p_group_id] = 0
    else
      params[:p_group_id] = 1
    end
    item = @model.new#.readable
    item.search params
    item.order params[:sort], "gis_layers.updated_at desc"
    @items = item.find(:all, :include=>[:layers_managers], :select => "gis_layers.*, gis_layers_managers.group_id")
    @count_hash = {}
    @items.each do |x|
      admin_group = x.admin_group
      if admin_group
        if @count_hash[admin_group.id].blank?
          @count_hash[admin_group.id] = {:count =>1 , :item => x, :admin_group => admin_group}
        else
          @count_hash[admin_group.id][:count] += 1
        end
      end
    end unless @items.blank?
  end


  def show
    @item = Gis::Layer.where(:id => params[:id]).first
    return http_error(404) if @item.blank?
    @assortments = @item.assortments
    @maps  = @item.maps
    @editable_groups = Gis::LayersManager.where(:layer_id => @item.id, :role_kind => "editor")
    @available_groups = Gis::LayersManager.where(:layer_id => @item.id, :role_kind => "user")
    _show @item
  end

  def new
    @item = Gis::Layer.new({
      :state        => 'enabled',
      :public_state => 'internal',
      :user_kind    => 2,
      :is_internal  => 1,
      :srid         => 2446,
      :kind         => "vector",
      :opacity      => 0.7
    })
    @item.set_tmp_id
    @manager_groups = @item.get_manager_groups(params)
  end

  def edit
    @item = Gis::Layer.where(:id => params[:id]).first
    return http_error(404) if @item.blank?
    return authentication_error(403) unless @item.editable?
    @item.set_tmp_id
    @manager_groups = @item.get_manager_groups(params)
  end

  def create
    upload_file = params[:item][:upload]
    params[:item].delete(:upload)
    @item = Gis::Layer.new(params[:item])
    @layer_file = Gis::LayerFile.new
    @manager_groups = @item.get_manager_groups(params)
    folder_ids = []
    map_ids = []
    if @item.save
      @item.save_managers(@manager_groups)
      file_save = @layer_file.save_with_layer(@item.id, upload_file,@item.srid)
      @item.save_files
      @item.cache_clear(folder_ids, map_ids)
      return redirect_to url_for({:controller => "gis/admin/layers/legends", :action => :new, :layer_id => @item.id}) if file_save && @item.kind == "file"
      if  upload_file
        if file_save
          flash[:notice] = "登録処理が完了しました。"
        else
          flash[:notice] = "レイヤー設定の登録のみ完了しました。ファイルの登録を完了できませんでした。管理者に問い合わせてください。"
        end
      else
        flash[:notice] = "登録処理が完了しました。"
      end
      return redirect_to url_for(:action => :index)
    else
      return render :action => :new
    end
  end

  def update
    @item = Gis::Layer.where(:id => params[:id]).first
    folder_ids = @item.layer_folder_ids
    map_ids = @item.layer_map_ids
    upload_file = params[:item][:upload]
    params[:item].delete(:upload)
    @item.attributes = params[:item]
    @layer_file = Gis::LayerFile.where(:layer_id => params[:id]).first || Gis::LayerFile.new
    @manager_groups = @item.get_manager_groups(params)
    if @item.save
      @item.save_managers(@manager_groups)
      file_save = @layer_file.save_with_layer(@item.id, upload_file,@item.srid)
      @item.save_files
      @item.cache_clear(folder_ids, map_ids)
      return redirect_to url_for({:controller => "gis/admin/layers/legends", :action => :new, :layer_id => @item.id}) if file_save && @item.kind == "file"
      if  upload_file
        if file_save
          flash[:notice] = "登録処理が完了しました。"
        else
          flash[:notice] = "レイヤー設定の登録のみ完了しました。ファイルの登録を完了できませんでした。管理者に問い合わせてください。"
        end
      else
        flash[:notice] = "登録処理が完了しました。"
      end
      return redirect_to url_for(:action => :index)
    else
      return render :action => :edit
    end
  end

  def destroy
    @item = Gis::Layer.where(:id => params[:id]).first
    folder_ids = @item.layer_folder_ids
    map_ids = @item.layer_map_ids
    _destroy @item do
      cache_item = Gis::Layer.new
      cache_item.cache_clear(folder_ids, map_ids)
    end
  end

private
  def switch_layout
    case params[:action].to_s
    when 'side_menu'
      "admin/gis/plain"
    when 'show'
      "admin/gis/base"
    when 'new'
      "admin/gis/base"
    when 'create'
      "admin/gis/base"
    when 'edit'
      "admin/gis/base"
    when 'update'
      "admin/gis/base"
    else
      "admin/gis/base_2_column"
    end
  end

end
