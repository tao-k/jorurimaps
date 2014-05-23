# encoding: utf-8
class System::RelatedLink < ActiveRecord::Base
  include System::Model::Base
  include System::Model::Base::Config
  include System::Model::Operator
  include System::Model::SortNo
  validates :title,         :presence => true
  validates :url,           :presence => true
  validates :sort_no,       :presence => true, :numericality => {:allow_blank => true}



  def web_state_select
    [["公開","public"], ["非公開","closed"]]
  end

  def web_state_show
    web_state_select.each{|a| return a[0] if a[1] == web_state}
  end


  def parent_category_select(options={})
    if options[:include_blank]
      ret = [["なし",nil]]
    else
      ret = []
    end
    ret = ret.concat(Gis.yaml_to_array_for_select("gis_link_parent_category"))
    return ret
  end

  def parent_category_show
    select = parent_category_select
    categories = []
    select.each{|a|
       categories << a[0] if a[1] == parent_category_id_0
       categories << a[0] if a[1] == parent_category_id_1
       categories << a[0] if a[1] == parent_category_id_2
     }

    return nil if categories.blank?
    return categories.join(" , ")
  end

  def cache_clear
    parent_category_select.each do |category|
      Rails.cache.delete "related_link_#{category[1]}"
    end
  end

end
