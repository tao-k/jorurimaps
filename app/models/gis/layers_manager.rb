# encoding: utf-8
class Gis::LayersManager < ActiveRecord::Base
  include System::Model::Base
  include System::Model::Base::Config
  include System::Model::Search
  include System::Model::Operator

  self.primary_key = 'rid'


  belongs_to   :layer, :foreign_key => :layer_id, :class_name => 'Gis::Layer'
  belongs_to   :group,  :foreign_key => :group_id,  :class_name => 'System::Group'


  def role_kind_select
    [["編集可能","editor"],["利用可能","user"]]
  end

  def role_kind_show
    select = role_kind_select
    select.each{|a| return a[0] if a[1] == role_kind}
    return nil
  end

  def group_name
    return group.name unless group.blank?
    return "制限なし" if group_id == 0
    return nil
  end

end
