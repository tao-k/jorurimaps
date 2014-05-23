# encoding: utf-8
module Gis::IndPortalHelper

  def ind_qr_code(portal, full_uri, size=150)
    full_uri = full_uri
    full_uri = full_uri.chop if full_uri.ends_with?('/')
    url = "#{full_uri}/#{portal.code}/" unless portal.blank?
    ret = "https://chart.googleapis.com/chart?cht=qr&chs=#{size}x#{size}&chl=#{CGI.escape(url)}"
    return ret
  end


  def qr_code(url, size=150)
    ret = "https://chart.googleapis.com/chart?cht=qr&chs=#{size}x#{size}&chl=#{CGI.escape(url)}"
    return ret
  end

  def layer_data_count(portal,web_state,layer_ids=nil)
    count = Rails.cache.read "portal_data_count_#{portal.id}_#{web_state}"
    if count.blank?
      if layer_ids.blank?
        layer_ids = []
        folders = get_folders_from_item(portal, web_state)
        folders.each do |folder|
          f_layers = folder.layers
          f_layers.each do |layer|
            next if layer.kind != "vector"
            case web_state
            when "internal"
              next if layer.public_state == "closed"
            when "all"
              next if layer.public_state != "all"
            end
            next if layer.state != "enabled"
            layer_ids << layer.id
          end if f_layers
        end if folders
        layers = portal.layers
        layers.each do |layer|
          next if layer.kind != "vector"
          case web_state
          when "internal"
            next if layer.public_state == "closed"
          when "all"
            next if layer.public_state != "all"
          end
          next if layer.state != "enabled"
          layer_ids << layer.id
        end if layers
      end
      return 0 if layer_ids.blank?
      cnt = Gis::LayerDatum.new
      cnt.and :web_state, "public"
      cnt.and :state , "enabled"
      cnt.and :layer_id, layer_ids
      count = cnt.count(:all)
      Rails.cache.write "portal_data_count_#{portal.id}_#{web_state}", count
    end
    return count
  end

  def portal_photo_show(portal)
    photo = Misc::PortalPhoto.where(:web_state => "public", :portal_id=>portal.id).order(:sort_no).first
    ret = ""
    if photo.blank?
      return nil
    else
      ret = image_tag(photo.file_uri, :alt=>photo.caption)
    end
    return ret.html_safe
  end


  def portal_related_link_items(map)
    return Misc::PortalLink.get_index_cache(map)
  end

  def portal_recommend_items(map)
    return Misc::PortalRecommend.get_index_cache(map)
  end

  def portal_doc_url(map, item = nil)
    return "/#{map.code}/doc/index.html" if item.blank?
    return "/#{map.code}/doc/#{item.name}"
  end

  def preview_add_layer_window_url(map)
    url_for({:controller=>"/gis/admin/demos/tools", :action=>:select, :demo_id=>map.code})
  end

  def preview_form_action_url(map)
    url_for({:controller=>"/gis/admin/demos/searches", :action=>:index, :demo_id=>map.code})
  end

  def form_action_url(map)
    "/#{map.code}/search/"
  end

  def portal_about_url(map)
    "/#{map.code}/about.html"
  end

  def portal_sitemap_url(map)
    "/#{map.code}/sitemap.html"
  end

  def portal_inquiry_url(map)
    "/#{map.code}/inquiry.html"
  end

  def add_layer_window_url(map)
    "/gis/tools/select"
  end

end
