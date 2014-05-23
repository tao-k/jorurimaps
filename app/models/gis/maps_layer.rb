class Gis::MapsLayer < ActiveRecord::Base
  include System::Model::Base
  include System::Model::Base::Config
  include System::Model::Search
  include System::Model::Operator

  self.primary_key = 'rid'

  belongs_to   :map, :foreign_key => :map_id, :class_name => 'Gis::Map'
  belongs_to   :layer,  :foreign_key => :layer_id,  :class_name => 'Gis::Layer'

  belongs_to   :stack,  :foreign_key => :layer_id,  :class_name => 'Gis::Layer'

end
