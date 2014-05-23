module Gis::Controller::Public::Code
  def get_kind(kind)
    selects = Gis.yaml_to_array_for_select('Gis_facility_kind_code',:no_sort=>true)
    selects.each{|a| return a[0] if a[1] == kind}
    return nil
  end

  def get_area(area)
    item = System::City.find( :first, :conditions => ["rid = ?", area])
    return item unless item.blank?
    return nil
  end

  def get_equipment(equipments)
    result = []
    selects = Gis.yaml_to_array_for_select('ud_facility_options',:no_sort=>true)
    selects.each{|select|
      next if select[0].blank?
      options = []
      select[0].each{|a|
        if equipments.index(a[0])
          options << a[1]
        end
      }
      result << {:title => select[0][:title], :options=>options }  if !options.blank?
    }
    return result
  end

  def get_recommend_option(option)
    selects = Gis.yaml_to_array_for_select('ud_facility_agreement',:no_sort=>true)
    selects.each{|a| return a[0] if a[1] == option}
    return nil
  end

  def get_mobile_equipment(equipment)
    selects = Gis.yaml_to_array_for_select('ud_facility_option_mobile',:no_sort=>true)
    selects.each{|a| return a[0] if a[1] == equipment}
    return nil
  end

  def get_recommend_category(categories)
    ret = []
    return ret if categories.blank?
    item = Gis::MapRecommendCategory.new
    item.and :state, "public"
    item.and :code, categories
    recommend_categories = item.find(:all, :order=>:sort_no)
    return ret if recommend_categories.blank?
    recommend_categories.each do |cat|
      ret << cat.name
    end
    return ret
  end

end
