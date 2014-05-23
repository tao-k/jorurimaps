# encoding: utf-8
class Gis::LayerDataColumn < ActiveRecord::Base
  include System::Model::Base
  include System::Model::Base::Config
  include System::Model::Search
  include System::Model::Operator



  belongs_to :layer, :class_name => "Gis::Layer", :foreign_key => :layer_id
  def show_fld_columns
    return nil if show_fld.blank?
    ret = []
    show_fld.split(/,/).each do |fld|
      ret << eval("self.input_fld_#{fld}")
    end
    return ret.join(",")
  end




end
