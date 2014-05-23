# encoding: utf-8
module System::FormHelper
  def get_role_id(item_role_id, params_role_id)
    return item_role_id if params_role_id.to_i == 0
    return params_role_id
  end
end