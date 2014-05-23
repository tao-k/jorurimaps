# encoding: utf-8
class Gis::LocationPoint < ActiveRecord::Base
  include System::Model::Base
  include System::Model::Base::Config
  include System::Model::Operator
  include Gis::Model::Geometry
  set_rgeo_factory_for_column(:g, RGeo::Geographic.spherical_factory(:srid => 4326))

  before_save :save_geometry

  def save_geometry
    self.g = wgs84_factory.point(self.lng, self.lat)
  end

  def self.get_points(point_address)
    features = []
    if point_address
      addresses = []
      q_string = ""
      q_item = []
      q_array = []
      split_address = point_address.split(/[ 　]+/)
      split_address.each_with_index do |a, i|
        replace_number =  number_to_kanji(a)
        if replace_number[:replaced] == true
          if i == split_address.length - 1
            q_string += %Q( (address LIKE ? or address LIKE ? ) )
          else
            q_string += %Q( (address LIKE ? or address LIKE ? ) and )
          end
          q_item << %Q(%#{replace_number[:to_kanji]}%)
          q_item << %Q(%#{replace_number[:to_zenkaku]}%)
        else
          if i == split_address.length - 1
            q_string += %Q( address LIKE ? )
          else
            q_string += %Q( address LIKE ? and )
          end
          q_item << %Q(%#{a}%)
        end
      end
      q_array = [q_string].concat(q_item)
      items = Gis::LocationPoint.find(:all, :conditions => q_array, :order=>"city_code, lot_code")
      features = features.concat(items) unless items.blank?

      if features.blank?
        split_match = /^(京都府|.+?[都道府県])(大和郡山市|蒲郡市|小郡市|杵島郡大町町|山口市|鹿児島市|鈴鹿市|.+?郡.+?町|.+?郡.+?村|石狩市|伊達市|八戸市|盛岡市|奥州市|南相馬市|上越市|姫路市|宇陀市|黒部市|小諸市|富山市|岩国市|周南市|佐伯市|西海市|.*?[^0-9一二三四五六七八九十上下]区|四日市市|廿日市市|.+?市|.+?町|.+?村)(.*?)([0-9-]*?)$/
        addresses = point_address.scan(split_match)
        if !addresses.blank? && !addresses[0].blank?
          split_address = []
          pref = addresses[0][0]
          city = addresses[0][1]
          lot = addresses[0][2]
          number = addresses[0][3]
          if !lot.blank?
            lots = lot.scan(/^(.*町)(.*)$/)
            if lots && lots[0]
              split_address << {:column => "lot_name", :value=>lots[0][0]}
            else
              split_address << {:column => "lot_name", :value=>lot}
            end
          end
          split_address << {:column => "pref_name", :value=>pref} if !pref.blank?
          split_address << {:column => "city_name", :value=>city} if !city.blank?
          unless split_address.blank?
            match_query_array = []
            match_query = []
            match_item = []
            split_address.each do |a|
              next if a.blank?
              match_query << ["#{a[:column]} LIKE ? "]
              match_item << %Q(%#{a[:value]}%)
            end
            if !match_query.blank? && !match_item.blank?
              match_query_array = [match_query.join(" and ")].concat(match_item)
              items = Gis::LocationPoint.find(:all, :conditions => match_query_array, :order=>"lot_code")
              features = features.concat(items) unless items.blank?
            end
          end
        end
      end
    end
    return features
  end

  def self.number_to_kanji(address)
    ret = {:replaced => false, :address => address}
    return ret  unless address =~ /[0-9]/
    ret[:replaced] = true
    replace_kanji = [
      ["1", "一"],["2", "二"],["3", "三"],["4", "四"],["5", "五"],["6", "六"],["7", "七"],["8", "八"],["9", "九"],["10", "十"]
    ]
    replaced_kanji = address
    replaced_zenkaku = address
    replace_kanji.each do |r|
      replaced_kanji = replaced_kanji.gsub(/#{r[0]}/, r[1])
    end

    replace_zenkaku = [
      ["1", "１"],["2", "２"],["3", "３"],["4", "４"],["5", "５"],["6", "６"],["7", "７"],["8", "８"],["9", "９"],["10", "１０"],
    ]
    replace_zenkaku.each do |r|
      replaced_zenkaku = replaced_zenkaku.gsub(/#{r[0]}/, r[1])
    end
    ret[:to_kanji] = replaced_kanji.gsub(/-.*/, "")
    ret[:to_zenkaku] = replaced_zenkaku.gsub(/-.*/, "")
    return ret
  end

end
