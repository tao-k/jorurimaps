# encoding: utf-8
module Gis::Model::Base::Config
  def states
    {'disabled' => '無効', 'enabled' => '有効'}
  end

  def readable
    self.and "'readable'", 'readable'
    return self
  end

  def editable
    self.and "'editable'", 'editable'
    return self
  end

  def deletable
    self.and "'destroyable'", 'destroyable'
    return self
  end

  def enabled
    self.and "state", 'enabled'
    return self
  end

  def disabled
    self.and "state", 'disabled'
    return self
  end

  def readable?
    return true
  end

  def creatable?
    return true
  end

  def editable?
    return true if Core.user.has_auth?(:manager)
    if self.user_kind == 1
      return true if self.admin_user_id ==  Core.user.id
    elsif  self.user_kind == 2
      return true if self.admin_group_id ==  Core.user_group.id
    else
       return true
    end
    return false
  end

  def deletable?
    return true if Core.user.has_auth?(:manager)
    if self.user_kind == 1
      return true if self.admin_user_id ==  Core.user.id
    elsif  self.user_kind == 2
      return true if self.admin_group_id ==  Core.user_group.id
    else
       return true
    end
    return false
  end

  def enabled?
    return state == 'enabled'
  end

  def disabled?
    return state == 'disabled'
  end
end