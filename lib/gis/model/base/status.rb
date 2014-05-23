# encoding: utf-8
module Gis::Model::Base::Status

  def state_select
    [["有効","enabled"],["無効","disabled"]]
  end

  def state_show
    select = state_select
    select.each{|a| return a[0] if a[1] == state}
    return nil
  end


  def user_kind_select
    [["個別ユーザ管理",1],["所属管理",2]]
  end

  def user_kind_show
    select = user_kind_select
    select.each{|a| return a[0] if a[1] == user_kind}
    return nil
  end


end
