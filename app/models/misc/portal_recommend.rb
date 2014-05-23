# -*- encoding:utf-8 -*-
class Misc::PortalRecommend < ActiveRecord::Base
  include System::Model::Base
  include System::Model::Base::Config
  include System::Model::Search
  include System::Model::Operator
  include System::Model::SortNo

  serialize :column_flds
  validates :portal_id,             :presence => true
  validates :title,             :presence => true
  validates :column_flds,             :presence => true


  belongs_to :portal, :foreign_key => :portal_id, :class_name => 'Gis::Map'

  def web_status_select
    [["公開","public"], ["非公開","closed"]]
  end

  def web_status_show
    web_status_select.each{|a| return a[0] if a[1] == web_state}
  end

  def url_for_admin_search
    return "/" if self.portal.blank?
    "/_admin/gis/demos/#{self.portal.code}/searches/#{self.url}"
  end

  def url_for_search
    return "/" if self.portal.blank?
    "/#{self.portal.code}/search/#{self.url}"
  end


  def save_with_file(set_param, mode=:create)
    par_item = set_param[:item]
    return false if par_item.blank?

    self.title = par_item[:title]
    self.web_state = par_item[:web_state]
    self.name = par_item[:name]
    self.portal_id = par_item[:portal_id]
    set_columns = {}
    search_url = "?mode=recommend"
    set_param.each do |n, v|
      case n
      when /s_custom_field_/
        set_columns[n] = v
        search_url +=  "&#{n}=#{CGI.escape(v)}"
      when "s_area_code"
        set_columns[n] = v
        search_url +=  "&#{n}=#{v}"
      else
        next
      end
    end
    self.sort_no = par_item[:sort_no]
    self.column_flds = set_columns

    self.url = search_url
    self.valid?
    self.errors.add(:sort_no, "は数値で入力してください。")  unless par_item[:sort_no] =~ /^[0-9]+$/ unless par_item[:sort_no].blank?
    return false if self.errors.size > 0
    self.save
    return true
  end


  def self.get_index_cache(portal_item)
    items = Rails.cache.read "portal_recommend_#{portal_item.id}"
    if items.blank?
      items = Misc::PortalRecommend.find(:all, :conditions=>["portal_id = ? and web_state = ?", portal_item.id, "public"], :order=>:sort_no)
      Rails.cache.write "portal_recommend_#{portal_item.id}", items
    end
    return items
  end

  def cache_clear
    Rails.cache.delete "portal_recommend_#{self.portal.id}"
  end
end
