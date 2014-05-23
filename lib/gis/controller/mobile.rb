# encoding: utf-8
module Gis::Controller::Mobile
  def self.convert_for_mobile_body(body,session_id)
    @file_link = false

    body.gsub!(/<table[ ].*?>.*?<\/table>/iom) do |m|
      '' #remove
    end

    body.gsub!(/[\(]?(([0-9]{2}[-\(\)]+[0-9]{4})|([0-9]{3}[-\(\)]+[0-9]{3,4})|([0-9]{4}[-\(\)]+[0-9]{2}))[-\)]+[0-9]{4}/) do |m|
      "<a href='tel:#{m.gsub(/\D/, '\1')}'>#{m}</a>"
    end

    body.gsub!(/<img .*?src=".*?".*?>/iom) do |m|
      '' #remove
    end

    body = body.gsub(/'/,'"')
    body.gsub!(/<a .*?href=".*?".*?>.*?<\/a>/iom) do |m|
      uri   = m.gsub(/<a .*?href="(.*?)".*?>.*?<\/a>/iom, '\1')
      label = m.sub(/(<a .*?href=".*?".*?>)(.*?)(<\/a>)/i, '\2')
      convertd_link = self.convert_link(uri,label,session_id)
      convertd_link
    end
    body.gsub!(/<a .*?href=.*? .*?>.*?<\/a>/iom) do |m|
      if m =~ /<a .*?href=".*?".*?>.*?<\/a>/iom
        m
      else
        uri   = m.gsub(/<a .*?href=(.*?) .*?>.*?<\/a>/iom, '\1')
        label = m.sub(/(<a .*?href=.*?.*?>)(.*?)(<\/a>)/i, '\2')
        convertd_link = self.convert_link(uri,label,session_id)
        convertd_link
      end
    end
    if @file_link==true
      body += %Q(<br /><span style="color: #ff0000;">※パケット定額サービスに入っていない場合、高額の通信料が発生する場合があります。</span>)
    end
    return body
  end

  def self.convert_link(uri,label,session_id)
    @file_link = true if uri =~ /\.(pdf|doc|docx|xls|xlsx|jtd|jst|jpg|gif)$/i
    @file_link = true if uri =~ /_attach/i
    @file_link = true if uri =~ /download_object/i

    if uri =~ /^\/$|^(\/|\.\/|\.\.\/)/

      result = self.link_check(uri)
      if result == true

        unless session_id.blank?
          if uri =~ /\?/
            uri += "&_session_id=#{session_id}"
          else
            uri += "?_session_id=#{session_id}"
          end
        end
        converted_link = %Q(<a href="#{uri}">#{label}</a>)
      else
        converted_link = label
      end
    elsif uri =~ /http:\/\/localhost\//

      uri = uri.sub(/http:\/\/localhost\//,"/")
      uri = uri.sub(/limit=100|limit=30|limit=20|limit=40|limit=50/,"limit=10")
      result = self.link_check(uri)
      if result == true

        unless session_id.blank?
          if uri =~ /\?/
            uri += "&_session_id=#{session_id}"
          else
            uri += "?_session_id=#{session_id}"
          end
        end
        converted_link = %Q(<a href="#{uri}">#{label}</a>)
      else
        converted_link = label
      end
    else
      converted_link = %Q(<a href="#{uri}">#{label}</a>)
    end
    return converted_link
  end

  def self.link_check(uri)
    return false if uri =~ /system/
    return false if uri =~ /cms/
    return false if uri =~ /ud\/facilities/
    return false if uri =~ /ud\/facility_photos/
    return false if uri =~ /ud\/demos/
    return true
  end


end