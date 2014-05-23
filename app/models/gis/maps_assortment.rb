# encoding: utf-8
class Gis::MapsAssortment < ActiveRecord::Base
  include System::Model::Base
  include System::Model::Base::Config
  include System::Model::Search
  include System::Model::Operator

  acts_as_paranoid
  self.primary_key = 'rid'

  belongs_to   :map, :foreign_key => :map_id, :class_name => 'Gis::Map'
  belongs_to   :assortment,  :foreign_key => :assortment_id,  :class_name => 'Gis::Assortment'



end
