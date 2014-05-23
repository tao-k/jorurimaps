# encoding: utf-8
module System::Model::SortNo
  extend ActiveSupport::Concern
  
  included do
    before_validation :set_sort_no
    validates_numericality_of :sort_no, :only_integer => true
  end

  def get_max_sort_no
    max_item = self.class.find(:first, :order=>"sort_no desc")
    return 10 if max_item.blank?
    return 10 if max_item.sort_no.blank?
    return max_item.sort_no + 10
  end

 
protected
  
  def set_sort_no
    if new_record? && self.sort_no.blank?
      item = self.class.find(:first, :select => 'sort_no', :order => 'sort_no desc')
      self.sort_no = (item ? item.sort_no.to_i + 10 : 10)
    end
  end
end