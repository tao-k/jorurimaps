# -*- encoding:utf-8 -*-
class Misc::Inquiry < ActiveRecord::Base
  include System::Model::Base
  include System::Model::Base::Config
  include System::Model::Search
  include System::Model::Operator
  include System::Model::SortNo

  validates :inquiry_group_id,     :presence => true
  belongs_to   :inquiry_group,  :foreign_key => :inquiry_group_id,  :class_name => 'System::Group'


  def inquiry_department
    return nil if inquiry_group.blank?
    root_group = System::Group.where(:level_no =>1).first
    if root_group
      ret = root_group.name
    else
      ret = ""
    end
    case inquiry_group.level_no
    when 2
      ret += inquiry_group.name
    when 3
      ret += inquiry_group.parent.name unless inquiry_group.parent.blank?
      ret += inquiry_group.name
    else
      return nil
    end
  end

end
