# encoding: utf-8
class System::Area < ActiveRecord::Base

  set_primary_key "area_code"
  
  include System::Model::Base
  include System::Model::Base::Config
  include System::Model::UniqueId
  include System::Model::Operator
  include System::Model::Search

  acts_as_paranoid

  has_many :abris, :class_name => 'System::Abri', :foreign_key => "area_code"
  belongs_to :city, :class_name => "System::City", :foreign_key => "city_code"
  belongs_to :company, :class_name => "System::Company", :foreign_key => "company_code"
  belongs_to :zone, :class_name => "System::Zone", :foreign_key => "zone_rid"

  validates :area, :presence => true
  validates :public_status, :presence => true
  validates :order_no, :numericality => true, :allow_blank => true

  before_save :save_data

  def save_data
    city = self.city
    if city.present?
      self.city_name = city.name
      self.pref_rid = city.pref_id
      self.zone_rid = city.zone_rid
    end
  end

  def self.public_status_states
    return [['公開', "public"], ['非公開', "nonpublic"]]
  end
  def self.state_show(state, states = self.public_status_states)
    state_str = states.rassoc(state)
    if state_str.blank?
      return ""
    else
      return state_str[0]
    end
  end

  def search(params)
    params.each do |n, v|
      next if v.to_s == ''
      case n
      when 's_keyword'
        search_keyword v, :area
      end
    end if params.size != 0
    self
  end

  def editable?
    Core.user.has_auth?(:controller => 'system/admin/areas', :action => :edit, :city_id => self.city_code)
  end
  def deletable?
    Core.user.has_auth?(:controller => 'system/admin/areas', :action => :destroy, :city_id => self.city_code)
  end
end