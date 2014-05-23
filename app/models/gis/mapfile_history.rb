# encoding: utf-8
class Gis::MapfileHistory < ActiveRecord::Base
  include System::Model::Base
  include Gis::Model::Base::Config
  include System::Model::Search
  include System::Model::Operator
  include System::Model::FileUtil

  acts_as_paranoid

  belongs_to :admin_group, :class_name => "System::Group"
  belongs_to :admin_user, :class_name => "System::User"



  def send_mapfile
    mkdir_for_file(file_path)
    begin
      File.open(file_path, 'wb') { |f| f.write(body) }
    rescue => e
      dump e
    end
  end


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