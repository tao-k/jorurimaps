# encoding: utf-8
module Gis::FormHelper
  def fill_check(checked_value)
    return {:checked => false} if checked_value == 1 || checked_value.blank?
    return {:checked => true}
  end

  def map_area_options(options={:include_blank=>true})
    if options[:include_blank]
      ret = [["すべて",0]]
    else
      ret = []
    end
    city_items = city_code_select
    city_items.each do |city|
      ret << [city.name, city.rid]
    end unless city_items.blank?
    return ret
  end

  def item_pagination(next_item, prev_item, current, total,item_controller="/gis/admin/layers/data",item_action=:show)
    ret = %Q(<div class="simplePagination">)
    ret += %Q(<span class="prev">)
    if prev_item.blank?
      ret += "<<前のページ"
    else
      ret += link_to "<<前のページ", url_for(:controller=>item_controller, :action=>item_action, :id=>prev_item.rid)
    end
    ret += %Q(</span>)
    ret += %Q(　<span class="current">#{current}</span>　／　<span class="total">#{total}</span>　)
    ret += %Q(<span class="next">)
    if next_item.blank?
      ret += "次のページ>>"
    else
      ret += link_to "次のページ>>", url_for(:controller=>item_controller, :action=>item_action, :id=>next_item.id)
    end
    ret += %Q(</span>)
    ret += %Q(</div>)
    return ret.html_safe
  end


  def url_style(item)
    ret = case item.kind
    when "wms"
      ""
    else
      "display: none;"
    end
    return ret
  end

  def upload_style(item)
    ret = case item.portal_kind
    when 1
      ""
    when 2
      ""
    when 3
      "display: none;"
    when 4
      "display: none;"
    end
  end

  def mapfile_select
    items = Gis::Mapfile.find(:all, :order=>"file_name")
    return items
  end

  def mapfile_options(options={:include_blank=>false})
    if options[:include_blank]
      ret = [["　　　　　",nil]]
    else
      ret = []
    end
    mapfile_items = mapfile_select
    mapfile_items.each do |mapfile|
      ret << [ "#{mapfile.title}（#{mapfile.file_name}）", mapfile.id ]
    end unless mapfile_items.blank?
    return ret
  end

  def folder_select
    if Core.user.has_auth?(:manager)
      items = Gis::Assortment.find(:all, :include=>[:admin_group], :order=>"system_groups.code")
    else
      item = Gis::Assortment.new
      group_condition  = Condition.new()
      group_condition.or do |cond|
        cond.or "sql", "(user_kind = 2 and admin_group_id = #{Core.user_group.id})"
        cond.or "sql", "(user_kind = 1 and admin_user_id = #{Core.user.id})"
      end
      web_state = Condition.new()
      web_state.or do |web_cond|
        web_cond.or :web_state, '=', "all"
        web_cond.or do |internal_web|
          internal_web.and group_condition
          internal_web.and :web_state, '=', "internal"
        end
      end
      item.and web_state
      items = item.find(:all, :include=>[:admin_group], :order=>"system_groups.sort_no, system_groups.code")
    end
    return items
  end

  def folder_grouped_options(options={})
    ret = {}
    folder_items = folder_select
    group_s_name = ""
    new_array = []
    folder_items.each_with_index do |folder, i|
      if folder.admin_group
        folder_group_name = "#{folder.admin_group.code}#{folder.admin_group.name}"
      else
        folder_group_name = "000000所属不明"
      end
      if group_s_name.blank?
        group_s_name = folder_group_name
        new_array = []
        new_array << [folder.title, folder.id]
      else
        if group_s_name != folder_group_name
          new_array = []
          new_array << [folder.title, folder.id]
          group_s_name = folder_group_name
        else
          new_array << [folder.title, folder.id]
        end
      end
      ret[group_s_name] = new_array
    end unless folder_items.blank?
    return ret
  end


  def folder_options(options={:include_blank=>false})
    if options[:include_blank]
      ret = [["　　　　　",nil]]
    else
      ret = []
    end
    folder_items = folder_select
    folder_items .each do |folder|
      ret << ["#{folder.title}（#{folder.admin_group_name}）", folder.id]
    end unless folder_items.blank?
    return ret
  end


  def layer_select
    if Core.user.has_auth?(:manager)
      items = Gis::Layer.find(:all, :include=>[:admin_group], :order=>"system_groups.code")
    else
      item = Gis::Layer.new
      group_condition  = Condition.new()
      group_condition.or do |cond|
        cond.or "sql", "(user_kind = 2 and admin_group_id = #{Core.user_group.id})"
        cond.or "sql", "(user_kind = 1 and admin_user_id = #{Core.user.id})"
        cond.or "sql", "gis_layers_managers.group_id = #{Core.user_group.id}"
        cond.or "sql", "gis_layers_managers.group_id = 0"
      end
      web_state = Condition.new()
      web_state.or do |web_cond|
        web_cond.or :public_state, '=', "all"
        web_cond.or do |internal_web|
          internal_web.and group_condition
          internal_web.and :public_state, '=', "internal"
        end
      end
      item.and web_state
      item.and "gis_layers.state", "enabled"
      items = item.find(:all, :include=>[:layers_managers,:admin_group], :select => "gis_layers.*, gis_layers_managers.group_id", :order=>"system_groups.code")
    end

    return items
  end

  def layer_grouped_options(options={})
    ret = {}
    layer_items = layer_select
    group_s_name = ""
    new_array = []
    layer_items.each_with_index do |layer, i|
      if layer.admin_group
        layer_group_name = "#{layer.admin_group.code}#{layer.admin_group.name}"
      else
        layer_group_name = "000000所属不明"
      end
      if group_s_name.blank?
        group_s_name = layer_group_name
        new_array = []
        new_array << ["#{layer.title}（#{layer.code}）", layer.id]
      else
        if group_s_name != layer_group_name
          new_array = []
          new_array << ["#{layer.title}（#{layer.code}）", layer.id]
          group_s_name = layer_group_name
        else
          new_array << ["#{layer.title}（#{layer.code}）", layer.id]
        end
      end
      ret[group_s_name] = new_array
    end unless layer_items.blank?
    return ret
  end

  def map_select(options)
    if Core.user.has_auth?(:manager)
      items = Gis::Map.find(:all, :include=>[:admin_group], :order=>"system_groups.code")
    else
      item = Gis::Map.new
      group_condition  = Condition.new()
      group_condition.or do |cond|
        cond.or "sql", "(user_kind = 2 and admin_group_id = #{Core.user_group.id})"
        cond.or "sql", "(user_kind = 1 and admin_user_id = #{Core.user.id})"
      end
      web_state = Condition.new()
      web_state.or do |web_cond|
        web_cond.or :web_state, "public"
        web_cond.or do |internal_web|
          internal_web.and group_condition
          internal_web.and :web_state, ["internal","recognize","recognized"]
        end
      end
      item.and web_state
      if options[:all]
        #全種別のマップを表示
      else
        #レイヤーを保持するマップのみ表示
        item.and :portal_kind, [1,2]
      end
      items = item.find(:all, :include=>[:admin_group], :order=>"system_groups.sort_no, system_groups.code")
    end
    return items
  end
  def map_grouped_options(options={})
    ret = {}
    portal_items = map_select(options)
    group_s_name = ""
    new_array = []
    portal_items.each_with_index do |portal, i|
      if portal.admin_group
        portal_group_name = "#{portal.admin_group.code}#{portal.admin_group.name}"
      else
        portal_group_name = "000000所属不明"
      end
      if group_s_name.blank?
        group_s_name = portal_group_name
        new_array = []
        new_array << [portal.title, portal.id]
      else
        if group_s_name != portal_group_name
          new_array = []
          new_array << [portal.title, portal.id]
          group_s_name = portal_group_name
        else
          new_array << [portal.title, portal.id]
        end
      end
      ret[group_s_name] = new_array
    end unless portal_items.blank?
    return ret
  end

  def layer_options(options={:include_blank=>false})
    if options[:include_blank]
      ret = [["　　　　　",nil]]
    else
      ret = []
    end
    layer_items = layer_select
    layer_items .each do |layer|
      ret << ["#{layer.title}（#{layer.admin_group_name}/#{layer.code}）", layer.id]
    end unless layer_items.blank?
    return ret
  end

  def icon_select
    items = Gis::MapIcon.where(:state => "public").order(:sort_no)
    return items
  end

  def icon_options(options={:include_blank=>false})
    if options[:include_blank]
      ret = [["　　　　　",nil]]
    else
      ret = []
    end
    icon_items = icon_select
    icon_items .each do |icon_item|
      ret << [icon_item.title, icon_item.id]
    end unless icon_items.blank?
    return ret
  end

  def manager_select
    System::Group.find(:all, :conditions=>"state='enabled' and level_no = 3", :order => [:level_no,:code].join(',') )
  end

  def manager_options(options={:include_blank=>false})
    if options[:include_blank]
      ret = ["", nil]
    else
      ret = []
    end
    ret << ["制限なし",0]
    manager_items = manager_select
    manager_items .each do |manager|
      ret << [manager.name, manager.id]
    end unless manager_items.blank?
    return ret
  end

  def role_kind_options
    [["編集可能","editor"],["利用可能","user"]]
  end

  def portal_search_form_show(item,default_value=nil,id=nil)
    case item.form_type
    when "area"
      portal_select_area_code_form(item,default_value,id)
    when "text"
      portal_select_text_field(item,default_value,id)
    when "select"
      portal_select_pulldown(item,default_value,id)
    else
      nil
    end
  end

  def portal_select_text_field(item,default_value=nil,id = nil)
    id = "s_custom_field_#{item.id}" if id.blank?
    ret = text_field_tag "s_custom_field_#{item.id}", default_value,{:id=>id, :class=>"custom_field"}
    return ret.html_safe
  end

  def portal_select_area_code_form(item,default_value=nil,id=nil)
    id = "s_custom_field_#{item.id}" if id.blank?
    ret = select_tag("s_area_code" , options_from_collection_for_select(city_code_select, :rid, :name, default_value), {:include_blank=>"指定しない",:id=>id, :class=>"custom_field"} )
    return ret.html_safe
  end

  def portal_select_pulldown(item,default_value=nil,id=nil)
    id = "s_custom_field_#{item.id}" if id.blank?
    ret = select_tag("s_custom_field_#{item.id}", options_for_select(item.select.selects,default_value), {:include_blank=>"指定しない",:id=>id, :class=>"custom_field"})
    return ret.html_safe
  end

  def city_code_select
    items = System::City.order("sort_no").all
    return items
  end

  def select_area_code_form(f,default_value,object_colum="area_code")
    ret = f.select(object_colum.to_sym , options_from_collection_for_select(city_code_select, :rid, :name, default_value), {:include_blank=>"指定しない"} )
    return ret.html_safe
  end

end
