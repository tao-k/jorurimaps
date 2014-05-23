# encoding: utf-8
module Gis::PortalHelper



  def portal_qr_code(full_uri, size=150)
    url = full_uri
    ret = "https://chart.googleapis.com/chart?cht=qr&chs=#{size}x#{size}&chl=#{CGI.escape(url)}"
    return ret
  end

  def top_banner_url(category="top")
    ret = Rails.cache.read "portal_photo_#{category}"
    return ret if ret && ret != "no file"
    photo = Cms::PortalPhoto.where(:web_state => "public", :category=>category).order(:sort_no).first
    ret = ""
    if photo.blank?
      Rails.cache.write "portal_photo_#{category}", "no file"
      return nil
    else
      ret = photo.file_uri
      Rails.cache.write "portal_photo_#{category}", ret
    end
    return ret
  end



  def recommend_mark(item)
    ret = ""
    ret = " recommendMap" if item.is_recommend == 1
    return ret
  end


  def map_demo_link(item)
    ret = link_to item.title, url_for({:controller=>"gis/admin/demos", :action=>:show, :id=>item.code}), :target=>"_blank"
    return ret.html_safe
  end

  def short_messages
    items = System::ShortMessage.public_messages
    return items
  end

  def social_update_lists
    updates = System::SocialUpdate.find(:all, :order => 'published_at desc', :conditions =>  ["web_state = ? and published_at <= ? ", "public", Time.now], :limit=>5)
    return updates
  end

  def get_feed(class_title)
    feeds = Misc::FeedItem.order("published_at desc").has_genre(class_title).limit(10)
    return feeds
  end

  def update_public_uri(item)
    return "/doc/#{item.name}/"
  end

  def category_portal_photo(category)
    return "" if category.blank?

  end

  def current_class(category, current)
    return "current" if category == current
    return ""
  end

  def header_menu_piece_list

   header_menu_array = Rails.cache.read "portal_header_menu"
  if header_menu_array.blank?
    header_menu_array = []
    header_menu_array << {:class=>"top", :title=>"トップ", :url => "/"}
    map_item = Gis::Map.new
    categor_list = map_item.parent_category_select
    categor_list.each do |category|
      header_menu_array << {:class=>category[1], :title=>category[0], :url => "/gis/category/#{category[1]}/"}
    end
    Rails.cache.write "portal_header_menu", header_menu_array
  end

   return header_menu_array
  end

  def portal_banners(options={})
    item = System::LinkBanner.new
    item.and :web_state , "public"
    item.order params[:sort], "sort_no"
    condition = Condition.new()
    condition.and do |cond|
      cond.or :parent_category_id_0 , options[:category]
      cond.or :parent_category_id_1 , options[:category]
      cond.or :parent_category_id_2 , options[:category]
      cond.or :parent_category_id_0 , "all"
      cond.or :parent_category_id_1 , "all"
      cond.or :parent_category_id_2 , "all"
    end
    item.and condition
    items = item.find(:all)
    return items
  end


  def related_links(options={})
    item = System::RelatedLink.new
    item.and :web_state , "public"
    item.order params[:sort], "sort_no"
    condition = Condition.new()
    condition.and do |cond|
      cond.or :parent_category_id_0 , options[:category]
      cond.or :parent_category_id_1 , options[:category]
      cond.or :parent_category_id_2 , options[:category]
      cond.or :parent_category_id_0 , "all"
      cond.or :parent_category_id_1 , "all"
      cond.or :parent_category_id_2 , "all"
    end
    item.and condition
    items = item.find(:all, :limit=>20)
    return items
  end

  def class_title(category)
    header_menu_piece_list.each do |menu|
      return menu[:title] if menu[:class] == category
    end
    return nil
  end

  def map_tumb_path(map)
    ret = "/_common/themes/gis/images/main/map-thumbnail_default.gif"
    return map.thumb_uri unless map.thumb_uri.blank?
    return ret
  end

  def portal_kind_icon(map)
    case map.portal_kind
    when 1
      return "/_common/themes/gis/images/main/ic_map_system.gif"
    when 2
      return "/_common/themes/gis/images/main/ic_map_system.gif"
    when 3
      return "/_common/themes/gis/images/main/ic_map_externallink.gif"
    when 4
      return "/_common/themes/gis/images/main/ic_map_article.gif"
    when 5
      return "/_common/themes/gis/images/main/ic_map_system.gif"
    else
      return "/_common/themes/gis/images/main/ic_map_system.gif"
    end
  end

end
