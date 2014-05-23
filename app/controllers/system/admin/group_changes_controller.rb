# encoding: utf-8
class System::Admin::GroupChangesController < System::Controller::Admin::Base
  include System::Controller::Scaffold
  include System::Controller::Admin::Auth
  include Sys::Controller::Admin::Annual
  layout "admin/system/base"


  def initialize_scaffold
    Page.title = "組織変更"

    @is_role_admin = Core.user.has_auth?(:manager)
    return redirect_to "/_admin" unless @is_role_admin
    @start_at = get_start_at
  end

  def get_start_at
    fyears = System::GroupChangeDate.find(:first , :order=>"start_at DESC")
    if fyears.blank?
      return nil
    end
    if fyears.start_at.blank?
      return nil
    end

    start_at_str = fyears.start_at.strftime("%Y-%m-%d 00:00:00")
    return start_at_str
  end

  def index

    item = System::GroupChange.new
    show_start_at = @start_at
    if !show_start_at.blank?
      item.and :start_date, show_start_at
    end
    item.order :code
    @items = item.find(:all)
  end

  def show
    @item = System::GroupChange.find_by_id(params[:id])
  end

  def new
    @item = System::GroupChange.new({
      :change_division => 1,
      :start_date => @start_at
    }
    )
  end

  def create
    @item = System::GroupChange.new(params[:item])
    @item.start_date = @start_at if @item.start_date.blank?
    _create @item
  end

  def edit
    @item = System::GroupChange.find_by_id(params[:id])
  end

  def update
    @item = System::GroupChange.find_by_id(params[:id])
    @item.attributes = params[:item]
    @old_group = System::Group.find_by_id(@item.old_id)
    unless @old_group.blank?
      @item.old_code = @old_group.code
      @item.old_name = @old_group.name
    end
    if @item.save
      flash[:notice]="組織変更データを編集しました"
    else
      flash[:notice]="組織変更データの編集に失敗しました"
    end
    _update @item
  end


  def destroy
    @item = System::GroupChange.find(:first,:conditions=>["id = ?",params[:id]])
    _destroy @item
  end


  def csv_up
    if params[:do] == "up" && params[:item] && params[:item][:file]
      invalid_filetype = false
      if params[:item][:file].original_filename =~ /csv/
        ret = import_csv_data(params,@start_at)
      else
        invalid_filetype = true
        ret = {:result => false}
      end
      if ret[:result]
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

  def reflect
    do_annual_change(@start_at)
    flash[:notice]="作業を終了しました。"
    return redirect_to url_for({:action=>:index})
  end

end
