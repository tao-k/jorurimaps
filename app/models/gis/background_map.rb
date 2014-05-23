# encoding: utf-8
class Gis::BackgroundMap < ActiveRecord::Base
  include System::Model::Base
  include System::Model::Base::Config
  include System::Model::Search
  include System::Model::Operator
  include System::Model::SortNo


  acts_as_paranoid
  validates :code,              :presence => true
  validates :title,             :presence => true
  validates :kind,              :presence => true
  validates :state,             :presence => true
  validates_uniqueness_of :code, :scope => [:deleted_at]

  validates_each :url do |record, attr, value|
    if record.kind=="wms"
      record.errors.add attr, "を、入力してください。" if value.blank?
      record.errors.add attr, "の、形式がURLではありません。" if !value.blank? && !value =~ /^(http:\/\/|https:\/\/).*/
    end
  end

  def self.is_admin?(uid = Site.user.id)
    System::Model::Role.get(1, uid ,'background_maps', 'admin')
  end

  def webtis_v4_code_select
    [
    ["std","webtis_normal"],
    ["pale","webtis_monotone"],
    ["blank","webtis_blank"],
    ["pale","webtis_color" ],
    ["ort","webtis_ortho"]
    ]
  end

  def webtis_v4_code
    select = webtis_v4_code_select
    select.each{|a| return a[0] if a[1] == kind}
    return nil
  end

  def webtis_v4_extname_select
    [
    ["png","webtis_normal"],
    ["png","webtis_monotone"],
    ["png","webtis_blank"],
    ["png","webtis_color" ],
    ["jpg","webtis_ortho"]
    ]
  end

  def webtis_v4_extname
    select = webtis_v4_extname_select
    select.each{|a| return a[0] if a[1] == kind}
    return nil
  end

  def cache_clear
    Rails.cache.delete "base_layers"
    Rails.cache.delete "base_layers_internal"
  end

  def state_select
    [["公開","public"],["非公開","closed"]]
  end

  def state_show
    select = state_select
    select.each{|a| return a[0] if a[1] == state}
    return nil
  end

  def google_base
    ["gmap", "gsat","g_hybrid","g_physcal"]
  end

  def kind_select
    [
      ["基盤地図","webtis_normal"],
      ["基盤地図（淡色）","webtis_monotone"],
      ["基盤地図（白地図）","webtis_blank"],
      ["基盤地図（オルソ画像）","webtis_ortho"],
      ["Googleマップ","gmap"],
      ["Googleマップ　衛星","gsat"],
      ["Googleマップ（衛星＆道路）","g_hybrid"],
      ["オープンストリートマップ","osm"],
      ["その他","wms"]
      ]
  end

  def kind_show
    select = kind_select
    select.each{|a| return a[0] if a[1] == kind}
    return nil
  end
end
