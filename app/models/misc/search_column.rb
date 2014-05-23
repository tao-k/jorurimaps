# -*- encoding:utf-8 -*-
class Misc::SearchColumn < ActiveRecord::Base
  include System::Model::Base
  include System::Model::Base::Config
  include System::Model::Search
  include System::Model::Operator
  include System::Model::SortNo

  serialize :column_flds
  validate :check_form_type
  validates :label,             :presence => true
  belongs_to :portal, :foreign_key => :portal_id, :class_name => 'Gis::Map'
  has_one :select, :foreign_key => :config_id,  :class_name => 'Misc::SearchSelect'


  def check_form_type
    return if self.form_type != "area"
    if self.id
      cnt = Misc::SearchColumn.count(:all, :conditions=>["id != ? and form_type = ? and portal_id = ?",self.id, "area", self.portal_id])
    else
      cnt = Misc::SearchColumn.count(:all, :conditions=>["form_type = ? and portal_id = ?","area", self.portal_id])
    end
    self.errors.add :form_type, "に、市町村選択を2つ以上選択できません。" if cnt >= 1
  end

  def form_type_select
    [["テキストフィールド","text"],["プルダウン","select"],["市町村選択","area"]]
  end

  def form_type_show
    select = form_type_select
    select.each{|a| return a[0] if a[1] == form_type}
    return nil
  end

  def save_with_rels(params, mode = :create)
    if self.valid?
      if self.form_type != "area"
        #検索対象カラム設定
        #ret = ""
        column_conf = []
        select_items = []
        params[:layer_item].each_with_index do |item,i|
          next if item[1] == "0" || item[1] == 0
          column_conf << [item[0], item[1]]
          select_items.concat(get_layer_select_item(item[0], item[1])) if self.form_type == "select"
        end if params[:layer_item]
        self.column_flds = column_conf
        self.save
        select_items = ["指定なし",""] if select_items.blank?
        unless select_items.blank?
          select_items = select_items.uniq
          select_items = select_items.compact unless select_items.blank?
          new_select_item = Misc::SearchSelect.find(:first, :conditions=>["portal_id = ? and config_id = ?",self.portal_id ,self.id]) || Misc::SearchSelect.new
          new_select_item.portal_id = self.portal_id
          new_select_item.config_id = self.id
          new_select_item.selects = select_items
          new_select_item.save
        end
      else
        self.save
      end
      return true
    else
      return false
    end
  end

  def get_layer_select_item(layer_id,item_fld)
    ret = []
    items = Gis::LayerDatum.find(:all, :select=>"distinct #{item_fld}", :conditions=>["web_state = ? and state = ? and layer_id = ?","public","enabled",layer_id])
    items.each{|x|
      next if x[item_fld.to_sym].blank?
      ret << [x[item_fld.to_sym], x[item_fld.to_sym]]
    } unless items.blank?
    return ret
  end

  def self.refresh_selects(layer_id)
    search_column_items = Misc::SearchColumn.find(:all, :conditions=>["form_type = ?", "select"])
    return if search_column_items.blank?
    search_column_items.each do |item|
      layer_ids = []
      layer_items = []
      item.column_flds.each do |column_fld|
        layer_ids << column_fld[0]
        layer_items << column_fld
      end
      next if layer_ids.index(layer_id.to_s).blank?
      select_items = []
      layer_items.each do |layer_item|
        select_items.concat(item.get_layer_select_item(layer_item[0], layer_item[1]))
      end
      if select_items.blank?
        next
      else
        select_items = select_items.uniq
        select_items = select_items.compact unless select_items.blank?
        new_select_item = Misc::SearchSelect.find(:first, :conditions=>["portal_id = ? and config_id = ?",item.portal_id ,item.id]) || Misc::SearchSelect.new
        new_select_item.portal_id = item.portal_id
        new_select_item.config_id = item.id
        new_select_item.selects = select_items
        new_select_item.save
      end
    end
  end

  def self.get_search_config(field_params)
    cache_item = Rails.cache.read field_params
    if cache_item
      return cache_item
    else
      field_id = field_params.gsub(/s_custom_field_/,"")
      ret = Misc::SearchColumn.where(:id => field_id).first
      Rails.cache.write field_params, ret
      return ret
    end
  end

  def self.get_index_cache(portal_item)
    items = Rails.cache.read "search_configs_#{portal_item.id}"
    if items.blank?
      items = Misc::SearchColumn.find(:all, :conditions=>["portal_id = ?", portal_item.id], :order=>:sort_no)
      Rails.cache.write "search_configs_#{portal_item.id}",items
    end
    return items
  end

  def cache_clear
    Rails.cache.delete "search_configs_#{self.portal_id}"
  end

  def field_id
    if self.form_type == "area"
      field_id = "s_area_code"
    else
      field_id = "s_custom_field_#{self.id}"
    end
  end

  def field_value(value)
    return "　" if value.blank?
    if self.form_type == "area"
      area = System::City.where(:rid=>value).first
      return nil if area.blank?
      return area.name
    else
      return value
    end
  end

  def search_class
     ret = case self.form_type
     when "area"
       "area"
     when "text"
       "name"
     when "select"
       "category"
     else
       "area"
     end
     return ret
  end

  def now_class
     ret = case self.form_type
     when "area"
       "nowArea"
     when "text"
       "nowName"
     when "select"
       "nowCategory"
     else
       "area"
     end
     return ret
  end

end
