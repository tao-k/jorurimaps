# encoding: utf-8
class System::Pref < ActiveRecord::Base
  include System::Model::Base
  include System::Model::Base::Config
  include System::Model::UniqueId
  include System::Model::Operator
  include System::Model::SortNo
  include System::Model::Geometry

  acts_as_paranoid

  self.primary_key = :rid
  set_rgeo_factory_for_column(:g, RGeo::Geographic.spherical_factory(:srid => 4326))

  has_many :zones, :class_name => 'System::Zone', :order => 'sort_no'
  has_many :cities, :class_name => 'System::City', :order => 'sort_no'
  has_many :role_priv_areas, :class_name => 'System::RolePrivArea',
    :dependent => :destroy

  validates_presence_of :name

  before_save :update_geometry


  def self.is_admin?(uid = Site.user.id)
    System::Model::Role.get(1, uid ,'area_config', 'admin')
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
