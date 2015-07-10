# encoding: utf-8
class Gis::LayerDrawConfig <  ActiveRecord::Base
  include Sys::Model::Base::Config
  include System::Model::Base
  include System::Model::Operator
  include System::Model::FileUtil



  belongs_to :layer, :class_name => "Gis::Layer"
  belongs_to :mapfile, :class_name => "Gis::Mapfile"

  def update_mapfile
    to_mapfile = self.mapfile || Gis::Mapfile.new
    mapfile_body = ""
    mapfile_tpl = %Q(#{Rails.root.to_s}/template/#{self.geometry_type}.tpl)
    return false unless File.exist?(mapfile_tpl)
    File::open(mapfile_tpl) {|f|
      mapfile_body = f.read
    }
    replace_list.each do |replace|
      mapfile_body = mapfile_body.gsub(/#{replace[0]}/, "#{replace[1]}")
    end

    to_mapfile.file_name = "gis_layer_#{self.layer_id}.map"
    to_mapfile.title = "#{self.layer.title}"
    to_mapfile.state = "enabled"
    to_mapfile.body = mapfile_body
    to_mapfile.user_kind = 2
    to_mapfile.admin_group_id = Core.user.groups[0].id
    to_mapfile.save({:validate=>false})
    to_mapfile.save_history

    self.update_column("mapfile_id" , to_mapfile.id)

    update_layer = Gis::Layer.where(:id => self.layer_id).first
    return false if update_layer.blank?
    update_layer.update_column("mapfile_id" , to_mapfile.id)
    update_layer.cache_clear
  end

  def replace_list
    ret = [
      ["##layer_name##", self.layer.code],
      ["##layer_id##", self.layer_id],
      ["##label_item##", self.label_item],
      ["##width##", self.line_width],
      ["##label_color##", color_transform(self.label_color)],
      ["##label_size##",self.label_size]
    ]
    case self.geometry_type
    when "point"
      if self.point_fill == 0
        ret <<  ["##point_color##", nil]
      else
        ret <<  ["##point_color##", %Q(COLOR #{color_transform(self.point_color)})]
      end
      ret <<  ["##label_position##", self.label_position]
    when "line"
       if self.line_fill == 0
         ret << ["##color##", nil]
         ret << ["##outline_color##", nil]
       else
         ret << ["##color##", %Q(COLOR #{color_transform(self.line_color)})]
         ret << ["##outline_color##", %Q(OUTLINECOLOR #{color_transform(self.line_color)})]
       end
    when "polygon"
      if self.line_fill == 0
        ret << ["##outline_color##", nil]
      else
        ret << ["##outline_color##", %Q(OUTLINECOLOR  #{color_transform(self.line_color)})]
      end
      if self.polygon_fill == 0
        ret << ["##color##", nil]
      else
        ret << ["##color##", %Q(COLOR #{color_transform(self.polygon_color)})]
      end

    end
    return ret
  end

  def label_size_select
    [[4, 4],[5,5],[6,6],[7,7],[8,8],[9,9],[10,10],[11,11],[12,12],[13,13],[14,14]]
  end

  def label_size_show
    label_size_select.each{|a| return a[0] if a[1] == label_size}
    return nil
  end

  def label_item
    return nil if self.label_column.blank?
    return %Q(LABELITEM "#{self.label_column}")
  end

  def color_transform(color)
    return "0 0 0 " if color.blank?
    ret = color.gsub(/rgb\(/, "")
    ret = ret.gsub(/,/, "")
    ret = ret.gsub(/\)/, "")
    return ret
  end

  def geometry_type_select
    [["点（ポイント）","point"],["線（ライン）","line"],["面（ポリゴン）","polygon"]]
  end

  def geometry_type_show
    geometry_type_select.each{|a| return a[0] if a[1] == geometry_type}
    return "point"
  end

  def label_position_select
    [
      ["自動","AUTO"],
      ["上揃え-左寄せ","ul"],["上揃え-中央寄せ","uc"],["上揃え-右寄せ","ur"],
      ["中央揃え-左寄せ","cl"],["中央揃え-中央寄せ","cc"],["中央揃え-右寄せ","cr"],
      ["下揃え-左寄せ","ll"],["下揃え-中央寄せ","lc"],["下揃え-右寄せ","lr"]
    ]
  end
  def label_position_show
    label_position_select.each{|a| return a[0] if a[1] == label_position}
    return nil
  end

  def label_column_select
    columns_set = Gis::LayerDataColumn.where(:layer_id => self.layer_id).first
    columns_array = []
    columns_array << ["表示しない", nil]
    if columns_set
      Gis::LayerDataColumn.column_names.each do |column|
        next if eval("columns_set.#{column}.blank?")
        if column =~ /input_fld/
          columns_array << [ eval("columns_set.#{column}"), column]
        else
          next
        end
      end
    end
    return columns_array
  end

  def label_column_show
    label_column_select.each{|a| return a[0] if a[1] == label_column}
    return nil
  end

  def line_width_select
    [
      ["0.5px", "0.5"],["1.0px", "1.0"],["1.5px", "1.5"],["2.0px", "2.0"],["2.5px", "2.5"],["3.0px", "3.0"],["3.5px", "3.5"],
      ["4.0px", "4.0"],["4.5px", "4.5"],["5.0px", "5.0"],["5.5px", "5.5"],["6.0px", "6.0"],["6.5px", "6.5"],["7.0px", "7.0"]
    ]
  end

  def line_width_show
    line_width_select.each{|a| return a[0] if a[1] == line_width}
    return nil
  end


end
