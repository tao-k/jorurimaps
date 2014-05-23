# encoding: utf-8
class System::County < ActiveRecord::Base
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
  belongs_to :zone, :class_name => 'System::Zone', :foreign_key => "zone_id"
  has_many :cities, :class_name => 'System::City', :foreign_key => "county_rid"
  validates_presence_of :name, :code

  before_save :save_geometry, :save_kind

  def pref_options
    items = System::Pref.find(:all, :order => 'sort_no')
    items.map{|item| [item.name, item.rid]}
  end

  def zone_options(prefs)
    items = System::Zone.find(:all, :conditions => ["pref_id = ?", prefs[0][1]], :order => 'sort_no')
    items.map{|item| [item.name, item.rid]}
  end

  def kind_select
    [["市","city"],["郡", "county"]]
  end

  def kind_show
    kind_select.each{|a| return a[0] if a[1]==kind}
    return nil
  end

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

  def save_kind
    kind_select.each{|a| self.kind =  a[1] if self.name =~ /#{a[0]}/}
  end
end
