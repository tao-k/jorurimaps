# encoding: utf-8
class Gis::AssortmentsLayer < ActiveRecord::Base
  include System::Model::Base
  include System::Model::Base::Config
  include System::Model::Search
  include System::Model::Operator

  self.primary_key = 'rid'

  belongs_to   :assortment,  :foreign_key => :assortment_id,  :class_name => 'Gis::Assortment'
  belongs_to   :layer, :foreign_key => :layer_id, :class_name => 'Gis::Layer'
  belongs_to   :stack, :foreign_key => :layer_id, :class_name => 'Gis::Layer'

end
