# encoding: utf-8
module System::Model::Operator
  extend ActiveSupport::Concern
  
  included do
    before_create :set_creator
    before_update :set_updator
    before_destroy :set_deletor
  end
  
protected
  
  def set_creator
    return if !new_record? && !changed?
    
    if Core.user && self.respond_to?(:created_user)
      self.created_user  = Core.user.name
    end
    if Core.user_group && self.respond_to?(:created_group)
      self.created_group = Core.user_group.name
    end
    
    set_updator
  end
  
  def set_updator
    return if !new_record? && !changed?
    
    if Core.user && self.respond_to?(:updated_user)
      self.updated_user  = Core.user.name
    end
    if Core.user_group && self.respond_to?(:updated_group)
      self.updated_group = Core.user_group.name
    end
  end
  
  def set_deletor
    if Core.user && self.respond_to?(:deleted_user)
      self.deleted_user  = Core.user.name
      #self.class.update_all("deleted_user = '#{self.deleted_user}'", ["id = ?", self.id])
      self.class.update_all("deleted_user = '#{self.deleted_user}'", ["#{self.class.primary_key} = ?", eval("self.#{self.class.primary_key}")])
    end
    if Core.user_group && self.respond_to?(:deleted_group)
      self.deleted_group = Core.user_group.name
      #self.class.update_all("deleted_group = '#{self.deleted_group}'", ["#{self.class.primary_key} = ?", self.id])
      self.class.update_all("deleted_group = '#{self.deleted_group}'", ["#{self.class.primary_key} = ?", eval("self.#{self.class.primary_key}")])
    end
  end
end