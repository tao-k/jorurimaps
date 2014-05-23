# encoding: utf-8
class Misc::SocialUpdate < ActiveRecord::Base
  include System::Model::Base
  include System::Model::Base::Config
  include System::Model::Operator
  validates :web_state,           :presence => true
  validates :title,           :presence => true, :length => { :maximum => 140 }

  validates :body,  :presence => true
  validates :published_at,     :presence => true
  validates :inquiry_group_id,     :presence => true

  before_create :set_doc_name
  belongs_to   :portal,         :foreign_key => :map_id,  :class_name => 'Gis::Map'
  belongs_to   :inquiry_group,  :foreign_key => :inquiry_group_id,  :class_name => 'System::Group'

  def set_tmp_id
    if tmp_id.blank?
      tmp_seq = Util::Sequencer.next_id('portal_updates_file', :md5 => true)
      self.tmp_id = tmp_seq.to_s
    end
  end

  def set_doc_name
    date = self.published_at.strftime('%Y%m%d')
    seq  = Util::Sequencer.next_id('portal_updates', :version => date)
    name = date + format('%04d', seq)
    self.name = Util::String::CheckDigit.check(name)
  end

  def inquiry_department
    return nil if inquiry_group.blank?
    root_group = System::Group.where(:level_no =>1).first
    if root_group
      ret = root_group.name
    else
      ret = ""
    end
    case inquiry_group.level_no
    when 2
      ret += inquiry_group.name
    when 3
      ret += inquiry_group.parent.name unless inquiry_group.parent.blank?
      ret += inquiry_group.name
    else
      return nil
    end
  end

  def web_state_select
    [["公開","public"], ["非公開","closed"]]
  end

  def web_state_show
    web_state_select.each{|a| return a[0] if a[1] == web_state}
  end

  def self.get_index_cache(portal)
    items = Rails.cache.read "update_index_piece_#{portal.id}"
    if items.blank?
      items = Misc::SocialUpdate.find(:all,
      :conditions=>["map_id = ? and web_state = ? and published_at <= ? ", portal.id, "public", Time.now.strftime("%Y-%m-%d %H:%M")],
      :order=>"published_at desc", :limit=>5)
      Rails.cache.write "update_index_piece_#{portal.id}",items
    end
    return items
  end


  def cache_clear
    Rails.cache.delete "update_index_piece_#{self.map_id}"
  end
end
