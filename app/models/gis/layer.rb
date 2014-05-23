# encoding: utf-8
class Gis::Layer < ActiveRecord::Base
  include System::Model::Base
  include Gis::Model::Base::Config
  include System::Model::Search
  include System::Model::Operator

  acts_as_paranoid
  belongs_to :admin_group, :class_name => "System::Group"
  belongs_to :admin_user, :class_name => "System::User"

  has_many :assortments_layers, :foreign_key => :layer_id,  :class_name => 'Gis::AssortmentsLayer', :dependent => :destroy
  has_many :assortments, :through => :assortments_layers,:source => :assortment, :order => 'gis_assortments_layers.updated_at'

  has_many :maps_layers, :foreign_key => :layer_id,  :class_name => 'Gis::MapsLayer', :dependent => :destroy
  has_many :maps, :through => :maps_layers,:source => :map, :order => 'gis_maps_layers.updated_at'

  has_one :layer_file,  :class_name => 'Gis::LayerFile'
  has_one :column_config,  :class_name => 'Gis::LayerDataColumn'
  has_one :draw_config,  :class_name => 'Gis::LayerDrawConfig'

  has_many :layers_managers, :foreign_key => :layer_id,  :class_name => 'Gis::LayersManager'
  has_many :manager_groups, :through => :layers_managers,:source => :group, :class_name => 'System::Group'
  has_many :editable_groups, :through => :layers_managers,:source => :group, :class_name => 'System::Group', :conditions => ['gis_layers_managers.role_kind = ?', 'editor']
  has_many :available_groups, :through => :layers_managers,:source => :group, :class_name => 'System::Group', :conditions => ['gis_layers_managers.role_kind = ?', 'user']

  before_validation :set_layer_setting
  after_destroy :destroy_rels

  belongs_to   :mapfile, :foreign_key => :mapfile_id, :class_name => 'Gis::Mapfile'

  validates :code,              :presence => true
  validates :title,             :presence => true

  validates_uniqueness_of :code, :scope => [:deleted_at]

  validates_each :mapfile_layer_name do |record, attr, value|
    record.errors.add attr, "を、入力してください。" if record.is_internal == 1 && value.blank? && record.kind != "kml" && record.kind !=  "gpx" && record.kind !=  "file"
  end

  def admin_group_name
    return "" if admin_group.blank?
    return admin_group.name
  end

  def set_layer_setting
    return if self.is_internal != 1
    case self.kind
    when "vector"
      vector_mapfile = Gis::Mapfile.where(:is_vector_mapfile=>1).first
      if vector_mapfile.blank?
        new_vector_mapfile = Gis::Mapfile.new
        new_vector_mapfile.is_vector_mapfile = 1
        new_vector_mapfile.save(:validate => false)
      else
        self.mapfile_id = vector_mapfile.id
      end
      mapfile_vector_layer_name = Application.config(:mapfile_vector_layer, "vector_layer")
      self.mapfile_layer_name = mapfile_vector_layer_name
    when "file"
      self.mapfile_layer_name = self.code
    when "raster"
      self.mapfile_layer_name = self.code
    else
    end
  end

  def destroy_rels
    Gis::LayerDataColumn.destroy_all(:layer_id=>self.id)
    Gis::LayerDatum.destroy_all(:layer_id=>self.id)
    Gis::LayerImportDatum.destroy_all(:layer_id=>self.id)
    Gis::LayerFile.destroy_all(:layer_id=>self.id)
    Gis::LegendFile.destroy_all(:layer_id=>self.id)
    Gis::LayerDrawConfig.destroy_all(:layer_id=>self.id)
  end


  def layer_folder_ids
    folder_layer = Gis::AssortmentsLayer.where(:layer_id => self.id)
    return nil if folder_layer.blank?
    return folder_layer.map{|a| a.assortment_id}
  end

  def layer_map_ids
    map_layer = Gis::MapsLayer.where(:layer_id => self.id)
    return nil if map_layer.blank?
    return map_layer.map{|a| a.map_id}
  end

  def cache_clear(folder_ids = layer_folder_ids, map_ids = layer_map_ids)
    folder_ids.each do |f_id|
      Rails.cache.delete "folder_layer_list_#{f_id}_all"
      Rails.cache.delete "folder_layer_list_#{f_id}_internal"
      Rails.cache.delete "folder_layer_list_#{f_id}_all_normal"
      Rails.cache.delete "folder_layer_list_#{f_id}_internal_normal"
      Rails.cache.delete "folder_layer_list_#{f_id}_all_stack"
      Rails.cache.delete "folder_layer_list_#{f_id}_internal_stack"
    end unless folder_ids.blank?
    map_ids.each do |m_id|
      Rails.cache.delete "map_layer_list_#{m_id}_all"
      Rails.cache.delete "map_layer_list_#{m_id}_internal"
      Rails.cache.delete "map_layer_list_#{m_id}_all_normal"
      Rails.cache.delete "map_layer_list_#{m_id}_internal_normal"
      Rails.cache.delete "map_layer_list_#{m_id}_all_stack"
      Rails.cache.delete "map_layer_list_#{m_id}_internal_stack"
    end unless map_ids.blank?
  end

  def export_items
    ret = []
    ret << "CSV出力" if csv_export == 1
    ret << "KML出力（ラベル有）" if kml_export == 1
    ret << "KML出力（ラベル無）" if kml_export_no_label == 1
    #ret << "shp出力" if shp_export == 1
    return nil if ret.blank?
    return ret.join(",")
  end

  def is_readable?
    return true if Core.user.has_auth?(:manager)
    if self.user_kind == 1
      return true if self.admin_user_id ==  Core.user.id
    elsif  self.user_kind == 2
      return true if self.admin_group_id ==  Core.user_group.id
    else
       return true
    end
    cnt = Gis::LayersManager.find(:all, :conditions=>["layer_id = ? and (group_id = ? or group_id = ?)", self.id,  Core.user_group.id, 0])
    return true if cnt.size > 0
    return false
  end

  def is_editable?
    return true if Core.user.has_auth?(:manager)
    if self.user_kind == 1
      return true if self.admin_user_id ==  Core.user.id
    elsif  self.user_kind == 2
      return true if self.admin_group_id ==  Core.user_group.id
    end
    cnt = Gis::LayersManager.find(:all, :conditions=>["layer_id = ? and (group_id = ? or group_id = ?) and role_kind = ? ", self.id,  Core.user_group.id, 0, "editor"])
    return true if cnt.size > 0
    return false
  end

  def set_tmp_id
    return unless self.tmp_id.blank?
    self.tmp_id = Util::Sequencer.next_id(:tmp, :md5 => true)
  end

  def save_files
    return if self.tmp_id.blank?
    Gis::LegendFile.update_all("layer_id = #{self.id}", "tmp_id = '#{self.tmp_id}'")
  end


  validates_each :url do |record, attr, value|
    record.errors.add attr, "を、入力してください。" if record.is_internal == 0 && value.blank?
  end

  def is_slideshow_state
    return nil if self.is_slideshow.blank?
    return "利用する"
  end

  def state_select
    [["有効","enabled"],["無効","disabled"]]
  end

  def state_show
    state_select.each{|a| return a[0] if a[1] == state}
    return nil
  end

  def public_state_select
    [["非公開","closed"],["内部公開","internal"],["全公開","all"]]
  end

  def public_state_show
    public_state_select.each{|a| return a[0] if a[1] == public_state}
    return nil
  end

  def user_kind_select
    [["個別ユーザ管理",1],["所属管理",2]]
  end

  def user_kind_show
    user_kind_select.each{|a| return a[0] if a[1] == user_kind}
    return nil
  end

  def is_internal_select
    [["内部",1],["外部",0]]
  end

  def opacity_select
    [
      ["100%", 1.0],["90%",0.9],["80%", 0.8],["70%",0.7],["60%",0.6],
      ["50%", 0.5],["40%",0.4],["30%", 0.3],["20%",0.2],["10%",0.1],["0%",0.0]
    ]
  end

  def opacity_show
    opacity_select.each{|a| return a[0] if a[1] == opacity_level}
    return nil
  end

  def is_internal_show
    is_internal_select.each{|a| return a[0] if a[1] == is_internal}
    return nil
  end

  def layer_kind_select
    [["ポイントデータ","vector"],["シェープファイル", "file"],["ラスタ","raster"],  ["KMLファイル","kml"], ["GPXファイル","gpx"]]
  end

  def srid_select
    [
      ["緯度・経度／世界測地系",4326],
      ["緯度・経度／日本測地系",4301],
      ["平面直角座標第1系",2443],
      ["平面直角座標第2系",2444],
      ["平面直角座標第3系",2445],
      ["平面直角座標第4系",2446],
      ["平面直角座標第5系",2447],
      ["平面直角座標第6系",2448],
      ["平面直角座標第7系",2449],
      ["平面直角座標第8系",2450],
      ["平面直角座標第9系",2452],
      ["平面直角座標第10系",2453],
      ["平面直角座標第11系",2454],
      ["平面直角座標第12系",2455],
      ["平面直角座標第13系",2456],
      ["平面直角座標第14系",2457],
      ["平面直角座標第15系",2458],
      ["平面直角座標第16系",2459],
      ["平面直角座標第17系",2460],
      ["平面直角座標第18系",2461]
   ]
  end

  def editable_kind
    return true if self.kind == "vector"
    return false
  end

  def draw_editable_kind
    return true if self.kind == "file"
    return false
  end

  def show_config
    columns_set = Gis::LayerDataColumn.where(:layer_id => self.id).first
    return [] if columns_set.blank?
    if columns_set.show_fld.blank?
      return []
    else
      ret = []
      columns_set.show_fld.split(/,/).each do |fld|
        ret << "input_fld_#{fld}"
      end
      return ret
    end
  end

  def get_manager_groups(params)
    if params[:manager]
      par_item = params[:manager]
      items = []
      par_item[:_group_id].each_with_index{|p_item, n|
        i = p_item[0]
        next if par_item[:_destroy] && par_item[:_destroy]["#{i}"]
        next if par_item[:_group_id]["#{i}"].to_i == self.admin_group_id
        items << Gis::LayersManager.new({
                 :layer_id => self.id,
                 :group_id => par_item[:_group_id]["#{i}"],
                 :role_kind => par_item[:_role_kind]["#{i}"]
               })
      }
      return items
    else
      return self.layers_managers
    end
  end

  def save_managers(manager_items)
    if layers_managers.blank?
      manager_items.each{|m|
        next if m.group_id.blank?
         m.layer_id = self.id
         m.save
      } unless manager_items.blank?
    else
      del_item = layers_managers
      create_item = manager_items
      layers_managers.each_with_index{ |m, ind|
        manager_items.each_with_index { |item, c_ind|
          if item.group_id == m.group_id
            del_item.delete_at(ind)
            create_item.delete_at(c_ind)
            if item.layer_id.blank?
              item.layer_id = self.id
              item.save
            end
          end
        }
      }

      create_item.each {|new_item|
        next if new_item.group_id.blank?
        new_item.layer_id = self.id
        new_item.save
      }

      del_item.each {|del|
        next if del.blank?
        del.destroy
      } unless del_item.blank?

    end
  end



  def get_option_columns
    columns_set = Gis::LayerDataColumn.where(:layer_id => self.id).first
    columns_array = []
    if columns_set
      Gis::LayerDataColumn.column_names.each do |column|
        next if eval("columns_set.#{column}.blank?")
        if column =~ /input_fld/
          columns_array << [column, eval("columns_set.#{column}")]
        else
          next
        end
      end
    end
    return columns_array
  end

  def get_option_column_hash
    columns_set = Gis::LayerDataColumn.where(:layer_id => self.id).first
    columns_hash = {}
    if columns_set
      Gis::LayerDataColumn.column_names.each do |column|
        next if eval("columns_set.#{column}.blank?")
        if column =~ /input_fld/
          columns_hash[column.to_sym] = eval("columns_set.#{column}")
        else
          next
        end
      end
    end
    return columns_hash
  end


  def get_column_open_csv
    show_fld_conf = self.show_config
    default_set = Gis.yaml_to_array_for_select("gis_layer_data_open_csv",:no_sort=>true)
    columns_set = Gis::LayerDataColumn.where(:layer_id => self.id).first
    columns_array = []
    default_set.each{|val|
        columns_array << [val[1], val[0]]
    }
    if columns_set
      Gis::LayerDataColumn.column_names.each do |column|
        next if eval("columns_set.#{column}.blank?")
        next if show_fld_conf.index(column).blank?
        if column =~ /input_fld/
          columns_array << [column, eval("columns_set.#{column}")]
        else
          next
        end
      end
    end
    return columns_array
  end

  def get_column_with_photo_settings
    default_set = Gis.yaml_to_array_for_select("gis_layer_data_photo_csv",:no_sort=>true)
    columns_set = Gis::LayerDataColumn.where(:layer_id => self.id).first
    columns_array = []
    default_set.each{|val|
        columns_array << [val[1], val[0]]
    }
    if columns_set
      Gis::LayerDataColumn.column_names.each do |column|
        next if eval("columns_set.#{column}.blank?")
        if column =~ /input_fld/
          columns_array << [column, eval("columns_set.#{column}")]
        else
          next
        end
      end
    end
    return columns_array
  end

  def get_column_settings(options={})
    columns_set = Gis::LayerDataColumn.where(:layer_id => self.id).first

    if options[:export] && !columns_set.blank?
      default_set = Gis.yaml_to_array_for_select("gis_layer_data_csv_export",:no_sort=>true)
    else
      default_set = Gis.yaml_to_array_for_select("gis_layer_data_csv",:no_sort=>true)
    end

    columns_array = []
    default_set.each{|val|
        columns_array << [val[1], val[0]]
    }
    if columns_set
      Gis::LayerDataColumn.column_names.each do |column|
        next if eval("columns_set.#{column}.blank?")
        if column =~ /input_fld/
          columns_array << [column, eval("columns_set.#{column}")]
        else
          next
        end
      end
    end
    return columns_array
  end

  def get_search_column_select
    columns_array = []
    columns_array << ["指定なし", 0]
    columns_array << ["タイトル", "name"]
    columns_set = Gis::LayerDataColumn.where(:layer_id => self.id).first
    if columns_set
      Gis::LayerDataColumn.column_names.each do |column|
        next if eval("columns_set.#{column}.blank?")
        if column =~ /input_fld/
          columns_array << [eval("columns_set.#{column}"), column]
        else
          next
        end
      end
    end
    return columns_array
  end

  def layer_kind_show
    layer_kind_select.each{|a| return a[0] if a[1] == kind}
    return nil
  end

  def opacity_level
    return 0.7 if opacity.blank?
    return opacity
  end

  def is_data_layer?
    return true if kind == "vector"
    return false
  end

  def layer_data_url
    return self.url if self.is_internal == 0
    return self.layer_data_file_path
  end

  def slide_show_class
    return nil if is_slideshow.to_i != 1
    return " showSlideCheck"
  end

  def layer_data_file_path
    "/gis/layers/#{self.id}/file"
  end

  def opacity_row_style
    return nil if kind != "vector"
    return "display: none;"
  end

  def export_row_style
    return "display: none;" if is_internal == 0
    return nil
  end

  def slide_show_style
    return "display: none;" if is_internal == 0
    return "display: none;" if kind != "vector"
    return nil
  end

  def srid_style
    return "display: none;" if is_internal == 0
    return nil if kind == "file"
    return "display: none;"
  end


  def file_upload_style
    return "display: none;" if is_internal == 0
    return nil if kind == "gpx" || kind == "kml" || kind == "file"
    return "display: none;"
  end

  def external_row_style
    return nil if is_internal == 0
    return "display: none;"
  end
  def internal_row1_style
    return "display: none;"
  end

   def internal_row2_style
     return "display: none;"
   end


  def search(params)
    params.each do |n, v|
      next if v.to_s == ''
      case n
      when 's_keyword'
        search_keyword v,:title
      when 'p_group_id'
        dump v.to_i
        if v.to_i == 1
        condition = Condition.new()
        condition.and do |cond|
            cond.or "sql", "(user_kind = 2 and admin_group_id = #{Core.user_group.id})"
            cond.or "sql", "(user_kind = 1 and admin_user_id = #{Core.user.id})"
            cond.or "sql", "gis_layers_managers.group_id = #{Core.user_group.id}"
            cond.or "sql", "gis_layers_managers.group_id = 0"
          end
          self.and condition
        elsif v.to_i != 0
          if Core.user.has_auth?(:manager)
            condition = Condition.new()
            condition.and do |cond|
                cond.or "sql", "(user_kind = 2 and admin_group_id = #{v})"
              end
            self.and condition
          else
            condition = Condition.new()
            condition.and do |cond|
                cond.or "sql", "(user_kind = 2 and admin_group_id = #{v})"
              end
            self.and condition
            u_condition = Condition.new()
            u_condition.and do |cond|
              cond.or "sql", "(user_kind = 2 and admin_group_id = #{Core.user_group.id})"
              cond.or "sql", "(user_kind = 1 and admin_user_id = #{Core.user.id})"
              cond.or "sql", "gis_layers_managers.group_id = #{Core.user_group.id}"
              cond.or "sql", "gis_layers_managers.group_id = 0"
            end
            self.and u_condition
          end

        end
      end
    end if params.size != 0

    return self
  end

end
