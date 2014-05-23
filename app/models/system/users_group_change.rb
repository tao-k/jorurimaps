# encoding: utf-8
class System::UsersGroupChange < ActiveRecord::Base
  include System::Model::Base
  include System::Model::Base::Config
  include System::Model::Operator
  include System::Model::Search
  acts_as_paranoid
  
  belongs_to :company, :class_name => 'System::Company'
  belongs_to :user, :class_name => 'System::User'
  belongs_to :curr_group, :class_name => 'System::Group'
  belongs_to :next_group, :class_name => 'System::Group'
  
  validates_presence_of :user_id, :change_type, :change_at, 
    :message => 'を正しく入力してください。'
  validates_presence_of :next_group_id, :count_flag, :sort_no, :if => %Q(change_type == 'change'),
    :message => 'を正しく入力してください。'
  validates_uniqueness_of :user_id, :scope => [:company_id, :deleted_at],
    :message => 'は既に登録済みです。'
  validates_numericality_of :sort_no, :only_integer => true, :if => %Q(change_type == 'change')
  
  before_save :set_change_at_time
  before_save :reset_next_group_id
  
  def change_types
    [['異動','change'],['退職','retire']]
  end
  
  def change_type_label
    change_types.rassoc(change_type)[0] rescue ''
  end
  
  def count_flags
    System::UsersGroup.new.count_flags
  end
  
  def count_flag_numbers
    System::UsersGroup.new.count_flag_numbers
  end
  
  def count_flag_label
    count_flags.rassoc(count_flag)[0] rescue ''
  end
  
  def next_group_name_from_root
    next_group.group_names_from_root rescue ''
  end
  
  def search(params)
    params.each do |n, v|
      next if v.to_s == ''
      case n
      when 's_keyword'
        search_keyword v, 'system_users.code', 'system_users.name'
      end
    end if params.size != 0
    self
  end
  
  def group_options
    company.group_options
  end
  
  def user_options
    item = System::User.new
    item.and 'system_users.state', 'enabled'
    item.and 'system_users.company_id', company_id
    if curr_group_id == '-1'
      item.and 'sql', "system_users.id NOT IN (select user_id from system_users_groups where company_id = '#{company_id}')"
    else
      item.and 'system_groups.id', curr_group_id
    end
    item.and 'system_groups.deleted_at', 'IS', nil
    item.and 'system_users_groups.deleted_at', 'IS', nil
    item.order 'system_users_groups.sort_no'
    items = item.find(:all, :include => [:groups])
    
    items.map{|item| [item.name, item.id]}
  end
  
  def execute
    case change_type
    when 'change'
      return execute_change_group
    when 'retire'
      return execute_retire
    end
    false
  end
  
private
  
  def execute_retire
    user.company_id = nil
    if user.user_groups.destroy_all && user.save(:validate => false)
      return true
    end
    false
  end
  
  def execute_change_group
    if user.user_groups.destroy_all && user.user_groups.create({
        :company_id => user.company_id, 
        :user_id    => user.id,
        :group_id   => next_group.id,
        :count_flag => count_flag,
        :sort_no    => sort_no
      })
      return true
    end
    false
  end
  
  def set_change_at_time
    if self.change_at_changed? && self.change_at.present?
      self.change_at = self.change_at.strftime('%Y-%m-%d 23:59:59')
    end
  end
  
  def reset_next_group_id
    if self.change_type_changed? && self.change_type == 'retire'
      self.next_group_id = nil
    end
  end
end