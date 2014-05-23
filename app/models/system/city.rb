# encoding: utf-8
class System::City < ActiveRecord::Base
  include System::Model::Base
  include System::Model::Base::Config
  include System::Model::UniqueId
  include System::Model::Operator
  include System::Model::SortNo
  include System::Model::Geometry

  acts_as_paranoid

  self.primary_key = :rid
  set_rgeo_factory_for_column(:g, RGeo::Geographic.spherical_factory(:srid => 4326))

  has_many :role_priv_areas, :class_name => 'System::RolePrivArea',
    :dependent => :destroy
  belongs_to :pref, :class_name => 'System::Pref', :foreign_key => "pref_id"
  belongs_to :zone, :class_name => 'System::Zone', :foreign_key => "zone_rid"
  belongs_to :county, :class_name => 'System::County', :foreign_key => "county_rid"

  validates_presence_of :pref_id, :name

  before_save :update_geometry

  def pref_options
    items = System::Pref.find(:all, :order => 'sort_no')
    items.map{|item| [item.name, item.rid]}
  end

  def zone_options(prefs)
    items = System::Zone.find(:all, :conditions => ["pref_id = ?", prefs[0][1]], :order => 'sort_no')
    items.map{|item| [item.name, item.rid]}
  end

  def county_options(prefs)
    items = System::County.find(:all, :conditions => ["pref_id = ?", prefs[0][1]], :order => 'code')
    items.map{|item| [item.name, item.rid]}
  end

private

  def update_geometry
    if self.lng_changed? || self.lat_changed?
      if new_record?
        self.g = wgs84_factory.point(self.lng, self.lat)
      else
        self.update_column(:g, wgs84_factory.point(self.lng, self.lat))
      end
    end
  end
end
