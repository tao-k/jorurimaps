# encoding: utf-8
class System::Option < ActiveRecord::Base
  include System::Model::Base
  include System::Model::Base::Config
  include System::Model::Operator

  acts_as_paranoid

  #validates_uniqueness_of :kind, :scope => [:deleted_at]
  validates :value,            :presence => true

  def kind_select
    [["シェープファイルのレコード数制限","record_limit"],["識別コード,更新情報取得URL,分野","atom_url"]]
  end


  def kind_show
    kind_select.each{|a| return a[0] if a[1] == kind}
  end


end
