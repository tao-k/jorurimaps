# encoding: utf-8
class Gis::MapConfig < ActiveRecord::Base
  include System::Model::Base
  include System::Model::Base::Config
  include System::Model::Operator

  serialize :layers
  belongs_to   :portal, :foreign_key => :portal_id, :class_name => 'Gis::Map'

end
