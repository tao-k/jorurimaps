# encoding: utf-8
class Gis::LayerDatum < ActiveRecord::Base
  include System::Model::Base
  include System::Model::Base::Config
  include System::Model::Search
  include System::Model::Operator
  include Gis::Model::Geometry
  set_rgeo_factory_for_column(:g, RGeo::Geographic.spherical_factory(:srid => 4326))


  validates :name,              :presence => true
  #validates :area_code,         :presence => true

  belongs_to :area, :class_name => "System::City", :foreign_key => :area_code
  belongs_to :icon, :class_name => "Gis::MapIcon", :foreign_key => :icon_id

  before_save :save_geometry

  def save_geometry
    self.g = wgs84_factory.point(self.lng, self.lat)
    self.icon_kind = self.icon.title if self.icon
  end


  has_many :photos, :class_name => "Gis::LayerDataPhoto", :foreign_key => :layer_data_id, :dependent => :destroy
  belongs_to :layer, :class_name => "Gis::Layer", :foreign_key => :layer_id

  def show_path(portal=nil)
    return "#" if portal.blank?
    return "/#{portal.code}/search/spot/#{self.id}.html"
  end

  def search(params)
    params.each do |n, v|
      next if v.to_s == ''
      case n
      when 's_keyword'
        search_keyword v,:name
      when 's_area_code'
        search_id v, :area_code unless v.to_i == 0
      end
    end if params.size != 0

    return self
  end

  def public_search(params,layer_ids)
    self.and :layer_id, layer_ids
    self.and "sql", "lat IS NOT NULL"
    self.and "sql", "lng IS NOT NULL"
    begin
      params.each do |n, v|
        next if v.to_s == ''
        case n
        when /s_custom_field_/
          search_form_item = Misc::SearchColumn.get_search_config(n)
          next if search_form_item.blank?
          next if search_form_item.column_flds.blank?
          condition = Condition.new()
          search_form_item.column_flds.each do |s_item|
            condition.or do |cond|
              cond.and :layer_id, '=', s_item[0]
              cond.and s_item[1].to_sym, 'LIKE', "%#{v}%"
            end
          end
          self.and condition
        when "s_area_code"
          search_id v, :area_code unless v.to_i == 0
        end
      end if params.size != 0
      return self
    rescue => e
      dump e
      return self
    end
  end

  def search_near_by(params,layer_ids)
    self.and :layer_id, layer_ids
    self.and "sql", "lat IS NOT NULL"
    self.and "sql", "lng IS NOT NULL"
    begin
      if params[:lat] && params[:lon]
        lat = params[:lat]
        lng = params[:lon]
        distance = 0.05
        distance = params[:distance] * 0.01 if !params[:distance].blank?
        self.and "sql", "ST_Distance(ST_GeomFromText('POINT(#{lng.to_f} #{lat.to_f})',4326), gis_layer_data.g) <= #{distance}"
        return self
      else
        return self
      end
    rescue => e
      dump e
      return self
    end
  end

  def get_public_photos(limit=2)
    public_photo = Gis::LayerDataPhoto.find(:all, :conditions=>["layer_data_id = ? and web_state = ?", self.id, "public"], :order=>"sort_no", :limit=>limit)
    return public_photo
  end

  def kml_geom
    g
  end


  def kml_content
    result_html = "<![CDATA["
    if self.address
      result_html += "住所：#{address}<br />";
    end

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