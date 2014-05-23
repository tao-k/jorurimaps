# -*- encoding:utf-8 -*-
class Misc::PortalLink < ActiveRecord::Base
  include System::Model::Base
  include System::Model::Base::Config
  include System::Model::Search
  include System::Model::Operator
  include System::Model::SortNo
  validates :title,         :presence => true
  validates :url,           :presence => true
  validates :sort_no,       :presence => true, :numericality => {:allow_blank => true}


  belongs_to :portal, :foreign_key => :portal_id, :class_name => 'Gis::Map'

  def web_state_select
    [["公開","public"], ["非公開","closed"]]
  end

  def web_state_show
    web_state_select.each{|a| return a[0] if a[1] == web_state}
  end

  def self.get_index_cache(portal_item)
    items = Rails.cache.read "portal_link_#{portal_item.id}"
    if items.blank?
      items = Misc::PortalLink.find(:all, :conditions=>["portal_id = ? and web_state = ?", portal_item.id, "public"], :order=>:sort_no)
      Rails.cache.write "portal_link_#{portal_item.id}", items
    end
    return items
  end

  def cache_clear
    Rails.cache.delete "portal_link_#{self.portal_id}"
  end

end
