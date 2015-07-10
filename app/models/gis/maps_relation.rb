class Gis::MapsRelation < ActiveRecord::Base
  include System::Model::Base
  include System::Model::Base::Config
  include System::Model::Search
  include System::Model::Operator

  self.primary_key = 'rid'

  belongs_to   :map, :foreign_key => :map_id, :class_name => 'Gis::Map'
  belongs_to   :relation,  :foreign_key => :relation_id,  :class_name => 'Gis::Map'

end
