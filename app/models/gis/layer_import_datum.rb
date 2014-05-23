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


  def kml_geom
    g
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
