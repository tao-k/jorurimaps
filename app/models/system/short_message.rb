# encoding: utf-8
require 'time'

class System::ShortMessage < ActiveRecord::Base
  include System::Model::Base
  include System::Model::Base::Config
  include System::Model::Operator

  validates :body,           :presence => true
  validates :sort_no,  :presence => true,  :uniqueness => true
  validates :release_at,     :presence => true
  validates :end_at,         :presence => true

  validate :release_end

  def self.public_messages

   messages = []
   now = Core.now

   self.find(:all, :order => 'sort_no', :conditions =>  ["? >= release_at and ? <= end_at", now, now]).each do |msg|
       messages.push msg.body
   end

   messages
  end

  def in_release_end?
    if !self.release_at.blank? && !self.end_at.blank? #どちらの日付もnilになっていないことを確認
      if Time.parse(Core.now) >= self.release_at && Time.parse(Core.now) < self.end_at
         return true
      else
         return false
      end
    end
  end

  def next_sort_no
    last = self.class.find(:first, :order => "sort_no DESC")

    if last
      last.sort_no + 1
    else
      0
    end
  end

  def no_tag_body
    ret = self.body
    ret = Hpricot(ret).inner_text.strip unless ret.blank?
    return ret
  end

  def inner_text!
    self.body = Hpricot(self.body).inner_text.strip
  end

  def release_end
    if !self.release_at.blank? && !self.end_at.blank? #どちらの日付もnilになっていないことを確認
      self.errors.add :end_at, "は、公開日より後の時間を入力してください。" if self.release_at >= self.end_at # 日付の前後関係を確認
    end
  end

  def cache_clear
    Rails.cache.delete "shortmessage_piece"
  end

end
