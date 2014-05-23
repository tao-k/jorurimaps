# encoding: utf-8
class System::Zone < ActiveRecord::Base
  include System::Model::Base
  include System::Model::Base::Config
  include System::Model::UniqueId
  include System::Model::Operator
  include System::Model::SortNo
  include System::Model::Geometry

  acts_as_paranoid

  self.primary_key = :rid
  set_rgeo_factory_for_column(:g, RGeo::Geographic.spherical_factory(:srid => 4326))

  belongs_to :pref, :class_name => 'System::Pref', :foreign_key => "pref_id"

  validates_presence_of :name, :code

  before_save :save_geometry

private

  def save_geometry
    if self.lng_changed? || self.lat_changed?
      if new_record?
        self.g = wgs84_factory.point(self.lng, self.lat)
      else
        self.update_column(:g, wgs84_factory.point(self.lng, self.lat))
      end
    end
  end
end
