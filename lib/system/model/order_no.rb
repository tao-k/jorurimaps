# encoding: utf-8
module System::Model::OrderNo
  extend ActiveSupport::Concern
  
  included do
    before_validation :set_order_no
    validates_numericality_of :order_no, :only_integer => true
  end
  
protected
  
  def set_order_no
    if new_record? && self.order_no.blank?
      item = self.class.find(:first, :select => 'order_no', :order => 'order_no desc')
      self.order_no = (item ? item.order_no + 1 : 1)
    end
  end
end