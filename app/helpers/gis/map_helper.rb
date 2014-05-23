# encoding: utf-8
module Gis::MapHelper

  def recognized_user(item)
    rec_user = Gis::MapsRecognizer.new#.readable
    rec_user.and :portal_id, item.id
    rec_user.and "sql",  "recognized_at IS NOT NULL"
    rec_users = rec_user.find(:all)
    ret = ""
    rec_user_names = []
    if rec_users.blank?
      ret = "承認済みユーザは存在しません。"
    else
      ret += "承認済みユーザ："
      rec_users.each do |user|
        next if user.blank?
        rec_user_names << "#{user.user.name}"
      end
      ret += rec_user_names.join(",")
    end
    return ret
  end

  def recognize_link(item, user)
    return nil if item.web_state != "recognize"
    rec_item = Gis::MapsRecognizer.where(:portal_id => item.id, :user_id => user.id).first
    return nil if rec_item.blank?
    return nil unless rec_item.recognized_at.blank?
    ret = ""
    ret += link_to("承認する", url_for({:controller=>"gis/admin/maps/recognizers",:action => :recognize, :map_id => item.id, :id => rec_item}), :confirm=>"承認を行います。よろしいですか？")
    return ret.html_safe
  end

  def map_icon_uri(item)
    if item.icon_path && item.icon_uri
      return item.icon_uri
    else
      return "/_common/themes/gis/images/ic_default_40px.png"
    end
  end

  def get_folders_from_item(item, web_state="all")
    folders = item.assortments
    ret = []
    folders.each do |folder|
      case web_state
      when "internal"
        next if folder.web_state == "closed"
      when "all"
        next if folder.web_state == "internal"
        next if folder.web_state == "closed"
      else
        next
      end
      ret << folder
    end unless folders.blank?
    return ret
  end

  def get_layers_from_item(item,web_state="all",layer_order=false)
    order_conf = "normal"
    order_conf = "stack" if layer_order
    if item.class.to_s=="Gis::Assortment"
      cache_id = "folder_layer_list_#{item.id}_#{web_state}_#{order_conf}"
    else
      cache_id = "map_layer_list_#{item.id}_#{web_state}_#{order_conf}"
    end
    cache_item = Rails.cache.read cache_id
    return cache_item if cache_item

    ret = []
    if layer_order
      layer_list = item.stacks
    else
      layer_list = item.layers
    end
    layer_list.each do |layer|
      next if layer.state == "disabled"
      case web_state
      when "internal"
        next if layer.public_state == "closed"
      when "all"
        next if layer.public_state == "internal"
        next if layer.public_state == "closed"
      else
        next
      end
      ret << layer
    end unless item.layers.blank?
    Rails.cache.write cache_id, ret
    return ret
  end


  def base_layers(map=nil)
    web_state_str = ""
    web_state_str = "_internal" if map && (map.web_state == "internal" || map.web_state == "closed")

    cache_item = Rails.cache.read "base_layers#{web_state_str}"

    if cache_item
      return items = cache_item
    else
      item = Gis::BackgroundMap.new
      item.and :state, "public"
      item.and :code, 'NOT IN', item.google_base if web_state_str == "_internal"
      item.order params[:sort], :sort_no
      items = item.find(:all)
      Rails.cache.write "base_layers#{web_state_str}", items
    end
    return items
  end



  def internal_maps
    items = Gis::Map.find(:all, :conditions=>["(portal_kind = ? or portal_kind = ?) and state = ? and (web_state = ? or web_state = ? or web_state = ? or web_state = ?)",
      1,2,"enabled","public","internal","recognize","recognized"], :order=>:sort_no)
  end

  def pref_portal_map_list(map=nil)
    if map
      items = Gis::Map.find(:all, :conditions=>["(portal_kind = ? or portal_kind = ?) and state = ? and code != ? and web_state = ? ",1,2,"enabled", map.code, "public"], :order=>:sort_no)
      portal_item = [map]
      items =portal_item.concat(items)
    else
      items = Gis::Map.find(:all, :conditions=>["(portal_kind = ? or portal_kind = ?) and state = ? and web_state = ?",1,2,"enabled","public"], :order=>:sort_no)
    end
  end

  def folder_select_style(map_item)
    case map_item.portal_kind
    when 3
      "display: none;"
    when 4
      "display: none;"
    else
      ""
    end
  end

  def remark_style(map_item)
    case map_item.portal_kind
    when 3
      ""
    else
      "display: none;"
    end
  end

  def link_style(map_item)
    case map_item.portal_kind
    when 3
      ""
    else
      "display: none;"
    end
  end

end
