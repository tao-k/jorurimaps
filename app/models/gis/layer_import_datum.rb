# encoding: utf-8
class Gis::LayerImportDatum < ActiveRecord::Base
  include System::Model::Base
  include System::Model::Base::Config
  include System::Model::Search
  include System::Model::Operator
  include Gis::Model::Geometry
  set_rgeo_factory_for_column(:g, RGeo::Geographic.spherical_factory(:srid => 4326))


  belongs_to :area, :class_name => "System::City", :foreign_key => :area_code
  belongs_to :layer, :class_name => "Gis::Layer", :foreign_key => :layer_id

  def point_name(label_column=nil)
    if label_column && !label_column.blank?
      begin
        return eval("self.#{label_column}")
      rescue
        return nil
      end
    else
      return self.input_fld_1
    end
  end

  def kml_geom
    g
  end

  def kml_text
    require 'builder'
    xml = ::Builder::XmlMarkup.new :indent => 2
    xml.instruct!(:xml, :encoding => "UTF-8")
    xml_obj = xml.kml('xmlns' => 'http://earth.google.com/kml/2.2'){
      xml.Document{
        xml.name(self.layer.title)
        xml.description("#{self.layer.title}のKMLデータ")
        xml.Placemark{
          xml.name(self.input_fld_1)
          xml.description{
            xml << self.kml_content
          }
          xml.Style('id' => 'style1'){
          case self.g.to_s
          when /POINT/
            xml.IconStyle{
              xml.Icon{
                xml.href("/_common/themes/ud/images/red-dot.png")
              }
            }
          else
            xml.LineStyle{
              xml.color("73FF0000")
              xml.width("5")
            }
            xml.PolyStyle{
              xml.color("73FF0000")
            }
          end
          }
          xml << %Q(      #{self.geom_kml})
        }

      }
    }
    return xml_obj
  end

  def import_geometry_from_wkt(wkt_txt)
    if wkt_txt =~ /GEOMETRYCOLLECTION/
      input_num =  1
      if wkt_txt =~/POLYGON/
        input_num = 3
      elsif wkt_txt =~ /LINESTRING/
        input_num = 2
      elsif wkt_txt =~ /POINT/
        input_num = 1
      end
      begin
        self.class.update_all("g = ST_CollectionExtract(ST_GeomFromText('#{wkt_txt}',  4326), #{input_num})", "rid = #{self.rid}")
        if input_num == 1
          self.class.update_all("lng = ST_X(g)", "rid = #{self.rid}")
          self.class.update_all("lat = ST_Y(g)", "rid = #{self.rid}")
        end
      rescue
      end
    else
      self.class.update_all("g = ST_GeomFromText('#{wkt_txt}',  4326)", "rid = #{self.rid}")
      if wkt_txt =~ /POINT/
        self.class.update_all("lng = ST_X(g)", "rid = #{self.rid}")
        self.class.update_all("lat = ST_Y(g)", "rid = #{self.rid}")
      end
    end
  end

  def search(params)
    params.each do |n, v|
      next if v.to_s == ''
      case n
      when 's_keyword'
        search_keyword v, :input_fld_1,:input_fld_2,:input_fld_3,:input_fld_4,:input_fld_5,:input_fld_6,:input_fld_7,:input_fld_8,:input_fld_9,:input_fld_10,
        :input_fld_11,:input_fld_12,:input_fld_13,:input_fld_14,:input_fld_15,:input_fld_16,:input_fld_17,:input_fld_18,:input_fld_19,:input_fld_20,
        :input_fld_21,:input_fld_22,:input_fld_23,:input_fld_24,:input_fld_25,:input_fld_26,:input_fld_27,:input_fld_28,:input_fld_29,:input_fld_30,
        :input_fld_31,:input_fld_32,:input_fld_33,:input_fld_34,:input_fld_35,:input_fld_36,:input_fld_37,:input_fld_38,:input_fld_39,:input_fld_40,
        :input_fld_41,:input_fld_42,:input_fld_43,:input_fld_44,:input_fld_45,:input_fld_46,:input_fld_47,:input_fld_48,:input_fld_49,:input_fld_50
      when 's_area_code'
        search_id v, :area_code unless v.to_i == 0
      end
    end if params.size != 0

    return self
  end

  def kml_content
    result_html = "<![CDATA["
    column_config = self.layer.get_option_columns
      show_fld_conf = self.layer.show_config
      column_config.each do |column|
      next if column[1].blank?
      next if show_fld_conf.index(column[0]).blank?
      value = eval(%Q(self.#{column[0]}))
      if value =~ /http/
        result_html += %Q(<a href="#{value}" target="_blank">#{value}</a>)
      else
        result_html += "#{column[1]}：#{value}<br />";
      end
    end if column_config
    result_html += "]]>"
    return result_html
  end



  def state_select
    [["有効","enabled"],["無効","disabled"]]
  end

  def state_show
    select = state_select
    select.each{|a| return a[0] if a[1] == state}
    return nil
  end

  def web_state_select
    [["公開","public"],["非公開","closed"]]
  end

  def web_state_show
    select = web_state_select
    select.each{|a| return a[0] if a[1] == web_state}
    return nil
  end

  def area_show
    return self.area.name unless self.area.blank?
    return nil
  end
end
