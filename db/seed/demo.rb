# encoding: utf-8

load "#{Rails.root}/db/seed/base.rb"

## method


def create_group(parent, level_no, sort_no, code, name, name_en)
  System::Group.create :parent_id => (parent == 0 ? 0 : parent.id),
    :level_no  => level_no,
    :sort_no   => sort_no,
    :state     => 'enabled',
    :ldap      => 0,
    :code      => code,
    :name      => name,
    :name_en   => name_en,
    :start_at  => Time.now
end


def create_user(auth_no, name, account, password)
  System::User.create :state => 'enabled', :ldap => 0, :auth_no => auth_no,
    :name => name, :code => account, :password => password
end

def import_map_thumnail(photo_item, path_prefix, original_file_path, original_file_name)
  if File.exist?(original_file_path)
    upload_file = nil
      File::open(original_file_path) {|f|
        upload_file =  f.read
      }
      extname = File.extname(original_file_name)
    upload_photo_size = photo_item.get_size(upload_file)
    tmp_id = photo_item.id.to_s
    dir = tmp_id.gsub(/(.*)(..)(..)(..)$/, '\1/\2/\3/\4/\1\2\3\4')
    directory = "/gis/portal/thumb/#{dir}/"
    file_name = "#{format('%08d', photo_item.id.to_s)}#{extname}"
    upload_path = Rails.root.to_s
    upload_path += '/' unless upload_path.ends_with?('/')
    upload_path += "public#{directory}#{file_name}"
    photo_item.thumb_uri = %Q(#{directory}#{file_name})
    photo_item.thumb_path = "/public#{directory}#{file_name}"
    photo_item.mkdir_for_file(upload_path)
    photo_item.mkdir_for_file(upload_path)
    File.delete(upload_path) if File.exist?(upload_path)
    File.open(upload_path, 'wb') { |f|
      f.write upload_file
    }
    photo_item.reduce(upload_path, 136, 90)
    photo_item.save(:validate=>false)
  end
end

def import_photo_data(photo_item, path_prefix, original_file_path, original_file_name,is_upload = false,get_size=false)
  if File.exist?(original_file_path)
    upload_file = nil
      File::open(original_file_path) {|f|
        upload_file =  f.read
      }
    extname = File.extname(original_file_name)
    if get_size
      upload_photo_size = photo_item.get_size(upload_file)
      photo_item.width = upload_photo_size[0]
      photo_item.height = upload_photo_size[1]
      photo_item.size = upload_file.size.to_i
    end
    tmp_id = photo_item.id.to_s
    dir = tmp_id.gsub(/(.*)(..)(..)(..)$/, '\1/\2/\3/\4/\1\2\3\4')
    directory = "#{path_prefix}#{dir}/"
    file_name = "#{format('%08d', tmp_id)}#{extname}"
    upload_path = Rails.root.to_s
    upload_path += '/' unless upload_path.ends_with?('/')
    if is_upload
      upload_path += "#{directory}#{file_name}"
      photo_item.file_path = "#{directory}#{file_name}"
    else
      upload_path += "public#{directory}#{file_name}"
      photo_item.file_path = "/public#{directory}#{file_name}"
    end
    photo_item.file_uri = %Q(#{directory}#{file_name})
    photo_item.mkdir_for_file(upload_path)
    photo_item.original_file_name = original_file_name
    File.delete(upload_path) if File.exist?(upload_path)
    File.open(upload_path, 'wb') { |f|
      f.write upload_file
    }
    photo_item.save(:validate=>false)
    return [upload_path,directory,file_name ]
  end
end


def import_shapfile_data(layer_code,layer_title,srid,filepath,geometry_type,label_column,label,point,line,polygon,line_width)
  layer_item = Gis::Layer.new({
    :state => "enabled",
    :public_state => "all",
    :code => layer_code,
    :title => layer_title,
    :kind => "file",
    :is_internal => 1,
    :mapfile_layer_name => layer_code,
    :opacity => 0.7,
    :user_kind => 2,
    :admin_group_id => 5,
    :srid => srid
  })
  layer_item.save(:validate=>false)

  Gis::Script::Import::Shape.import_data(layer_item, filepath)

  draw_config = Gis::LayerDrawConfig.new({
    :layer_id => layer_item.id,
    :geometry_type => geometry_type,
    :label_column => label_column,
    :point_color => point,
    :label_color => label,
    :line_color => line,
    :polygon_color =>polygon,
    :line_width => line_width
  })
  draw_config.save(:validate=>false)
  draw_config.update_mapfile
end

def import_layer_csv(csv_file,layer_id, icon_id)
  icon_item = Gis::MapIcon.where(:id => icon_id).first
  import_file =  %Q(#{Rails.root.to_s}/db/seed/demo/#{csv_file})
  if  File.exist?(import_file)
    csv = ""
    File::open(import_file) {|f|
      csv = f.read
    }
    if csv
      columns = []
      CSV.parse(csv) do |row|
        if columns.blank?
          row.each do |row_item|
            columns <<  row_item
          end
        else
          data = {}
          row.each_with_index{|row_item, i|
            next if row_item.blank?
            next if columns[i].blank?
            data[columns[i].to_sym] = row_item
          }
          if data
            if data[:area_code]
              area = System::City.where(:code => data[:area_code]).first
              data[:area_code] = area.rid if area
            elsif data[:area_name]
              area = System::City.where(:name => data[:area_name]).first
              data[:area_code] = area.rid if area
              data.delete :area_name
            end
            new_item = Gis::LayerDatum.new
            new_item.attributes = data
            new_item.layer_id = layer_id
            new_item.icon_id = icon_id
            new_item.state = "enabled"
            new_item.icon_kind = icon_item.title if icon_item
            new_item.save(:validate=>false)
          end
        end
      end
    end
  end
end

def category_list
  ret = [
  ["くらし", "kurashi"],
  ["健康・福祉", "fukushi"],
  ["教育・文化", "kyoikubunka"],
  ["観光・魅力", "kanko"],
  ["産業・しごと", "sangyoshigoto"],
  ["行政・まちづくり", "gyoseimachizukuri"],
  ["防災", "bousai"]
]
  return ret
end


def create_zone(pref_id,code,name,lat,lng,sort_no)
  new_item = System::Zone.new({
    :pref_id => pref_id,
    :name => name,
    :code => code,
    :sort_no => sort_no,
    :lat => lat,
    :lng => lng
  })
  new_item.save(:validate=>false)
  return new_item.rid
end

def create_city(pref_id,zone_id,code,name,lat,lng,sort_no)
  new_item = System::City.new({
    :pref_id => pref_id,
    :name => name,
    :code => code,
    :sort_no => sort_no,
    :lat => lat,
    :lng => lng
  })
  new_item.save(:validate=>false)
  return new_item.rid
end



## gis system data

r = System::Group.find(1)
p = create_group r, 2, 2 , '001'   , '企画部'        , 'kikakubu'
    create_group p, 3, 1 , '001001', '秘書広報課'    , 'hisyokohoka'
    create_group p, 3, 2 , '001002', '人事課'        , 'jinjika'
    create_group p, 3, 3 , '001003', '企画政策課'    , 'kikakuseisakuka'
    create_group p, 3, 4 , '001004', '行政情報室'    , 'gyoseijohoshitsu'
    create_group p, 3, 5 , '001005', 'IT推進課'      , 'itsuishinka'
p = create_group r, 2, 3 , '002'   , '総務部'        , 'somubu'
    create_group p, 3, 1 , '002001', '財政課'        , 'zaiseika'
    create_group p, 3, 2 , '002002', '庁舎建設推進室', 'chosyakensetsusuishinka'
    create_group p, 3, 3 , '002003', '管財課'        , 'kanzaika'
    create_group p, 3, 4 , '002004', '税務課'        , 'zeimuka'
    create_group p, 3, 5 , '002005', '納税課'        , 'nozeika'
p = create_group r, 2, 4 , '003'   , '市民部'        , 'shiminbu'
p = create_group r, 2, 5 , '004'   , '環境管理部'    , 'kankyokanribu'
p = create_group r, 2, 6 , '005'   , '保健福祉部'    , 'hokenhukushibu'
p = create_group r, 2, 7 , '006'   , '産業部'        , 'sangyobu'
p = create_group r, 2, 8 , '007'   , '建設部'        , 'kensetsubu'
p = create_group r, 2, 9 , '008'   , '特定事業部'    , 'tokuteijigyobu'
p = create_group r, 2, 10, '009'   , '会計'          , 'kaikei'
p = create_group r, 2, 11, '010'   , '水道部'        , 'suidobu'
p = create_group r, 2, 12, '011'   , '教育委員会'    , 'kyoikuiinkai'
p = create_group r, 2, 13, '012'   , '議会'          , 'gikai'
p = create_group r, 2, 14, '013'   , '農業委員会'    , 'nogyoiinkai'
p = create_group r, 2, 15, '014'   , '選挙管理委員会', 'senkyokanriiinkai'
p = create_group r, 2, 16, '015'   , '監査委員'      , 'kansaiin'
p = create_group r, 2, 17, '016'   , '公平委員会'    , 'koheiiinkai'
p = create_group r, 2, 18, '017'   , '消防本部'      , 'syobohonbu'
p = create_group r, 2, 19, '018'   , '住民センター'  , 'jumincenter'
p = create_group r, 2, 20, '019'   , '公民館'        , 'kominkan'


System::User.update_all({:name => "徳島　太郎"}, {:id => 3})
u4 = create_user 3, '徳島　花子'    , 'user2', 'user2'
u5 = create_user 3, '吉野　三郎'    , 'user3', 'user3'

g = System::Group.find_by_name_en('hisyokohoka')
System::UsersGroup.update_all(:group_id => g.id)
System::UsersGroup.create :user_id => 4, :group_id => g.id, :start_at  => Time.now
System::UsersGroup.create :user_id => 5, :group_id => g.id, :start_at  => Time.now


Gis::Assortment.update_all(:admin_group_id => g.id)
Gis::Layer.update_all(:admin_group_id => g.id)
Gis::Map.update_all(:admin_group_id => g.id)
Gis::Mapfile.update_all(:admin_group_id => g.id)

pref_item = System::Pref.new({
  :name => "徳島県",
  :code => "36000",
  :sort_no => 10,
  :lng  => 134.5589,
  :lat  => 34.065705
})
pref_item.save(:validate=>false)
pref_id = pref_item.rid

p = create_zone pref_id, "north", "北部"   , 34.171897390231216,134.52025569751655, 10
p = create_zone pref_id, 'west' , '西部'   , 33.95293596029271,134.02414003745437, 20
    create_city pref_id, p , "364894", "東みよし町", 34.03683091857906, 133.93691182136536,340
    create_city pref_id, p , "362085", "三好市", 34.02608354408118, 133.8071545958519,180
    create_city pref_id, p , "362077", "美馬市", 34.053423879706656, 134.16971683502197,170
    create_city pref_id, p , "364681", "つるぎ町", 34.03732435375613, 134.06410217285156,330
p = create_zone pref_id, 'east' , '東部'   , 33.93310074381965,134.53840888812923, 30
    create_city pref_id, p , "362034", "小松島市", 34.0047514761566, 134.5903730392456,130
    create_city pref_id, p , "362069", "阿波市", 34.08216606418767, 134.2357635498047,160
    create_city pref_id, p , "363219", "佐那河内村", 33.99309494438589, 134.4532746076584,210
    create_city pref_id, p , "363022", "上勝町", 33.88894250076998, 134.40200954675674,200
    create_city pref_id, p , "364045", "板野町", 34.14435849973523, 134.46262747049332,310
    create_city pref_id, p , "364053", "上板町", 34.121375321685605, 134.40486073493958,320
    create_city pref_id, p , "363014", "勝浦町", 33.9317038985491, 134.51118350028992,190
    create_city pref_id, p , "362026", "鳴門市", 34.17259491448747, 134.608815908432,120
    create_city pref_id, p , "364037", "藍住町", 34.12663767119703, 134.4951492547989,300
    create_city pref_id, p , "364029", "北島町", 34.12557634606008, 134.5469856262207,290
    create_city pref_id, p , "364011", "松茂町", 34.13377129542243, 134.58065271377563,280
    create_city pref_id, p , "362051", "吉野川市", 34.06624086342188, 134.35869455337524,150
    create_city pref_id, p , "363413", "石井町", 34.0746681736875, 134.4532746076584,220
    create_city pref_id, p , "362018", "徳島市", 34.07031576035026, 134.55491825938225,100
    create_city pref_id, p , "363421", "神山町", 33.966932529043596, 134.35034416615963,230
p = create_zone pref_id, 'south', '南部'   , 33.73226282546272,134.30233159256866, 40
    create_city pref_id, p , "363880", "海陽町", 33.60202706180481, 134.35199439525604,270
    create_city pref_id, p , "362042", "阿南市", 33.92176451115718, 134.65955257415771,140
    create_city pref_id, p , "363685", "那賀町", 33.85743983813179, 134.49663922190666,240
    create_city pref_id, p , "363839", "牟岐町", 33.66840538739385, 134.42054897546768,250
    create_city pref_id, p , "363871", "美波町", 33.7344726653164, 134.53525766730309,280

portal_photo = Cms::PortalPhoto.new({
  :web_state => "public",
  :title => "トップバナー",
  :caption => "ジョールリ市総合Web GIS",
  :category => "top",
  :sort_no => 10
})
portal_photo.save(:validate=>false)
portal_photo_path = %Q(#{Rails.root.to_s}/public/images/mainimage.png)
portal_photo_name = "mainimage.png"
import_photo_data(portal_photo, "/gis/images/category/", portal_photo_path, portal_photo_name)


category_list.each_with_index do |cat, i|
  n = i + 1
  category_photo = Cms::PortalPhoto.new({
    :web_state => "public",
    :title => "#{cat[0]}　タイトル画像",
    :caption => "ジョールリ市総合Web GIS",
    :category => cat[1],
    :sort_no => 10
  })
  category_photo.save(:validate=>false)
  category_photo_path = %Q(#{Rails.root.to_s}/db/seed/demo/img/0#{n}.jpg)
  category_photo_name = "0#{n}.jpg"
  import_photo_data(category_photo, "/gis/images/category/", category_photo_path, category_photo_name)
end


##gis demo util
System::SocialUpdate.create({
  :is_tweet => 0,
  :web_state => "public",
  :title => "ジョールリ市統合Web GISを公開しました！",
  :body =>  "○○○○○○○○○○○○○○○○　○○○○○○○○○○○○○○○○<br />○○○○○○○○○○○○○○○○　○○○○○○○○○○○○○○○○<br />○○○○○○○○○○○○○○○○　○○○○○○○○○○○○○○○○<br />",
  :published_at => Time.now,
  :inquiry_group_id => 5,
  :mail_to => "jorurimaps@demo.joruri.org",
  :tel => "（0000）00-0000",
  :fax => "（0000）00-0000 "
})
4.times do |i|
  System::SocialUpdate.create({
    :is_tweet => 0,
    :web_state => "public",
    :title => "サンプルマップ○○○○○○○○○○○を公開しました！",
    :body =>  "○○○○○○○○○○○○○○○○　○○○○○○○○○○○○○○○○<br />○○○○○○○○○○○○○○○○　○○○○○○○○○○○○○○○○<br />○○○○○○○○○○○○○○○○　○○○○○○○○○○○○○○○○<br />",
    :published_at => Time.now,
    :inquiry_group_id => 5,
    :mail_to => "jorurimaps@demo.joruri.org",
    :tel => "（0000）00-0000",
    :fax => "（0000）00-0000 "
  })
end
System::ShortMessage.create({
  :body => %Q(<a href="/bousai/" target="_blank">防災マップを事前に確認し、災害に備えよう！</a>),
  :release_at => Time.now,
  :end_at => Time.now + 2.day
})

System::RelatedLink.create({
  :title => "○○○○○○○",
  :url => "#",
  :sort_no => 10,
  :web_state => "public",
  :parent_category_id_0 => "all"
})

System::RelatedLink.create({
  :title => "○○○○○○○",
  :url => "#",
  :sort_no => 20,
  :web_state => "public",
  :parent_category_id_0 => "all"
})

System::RelatedLink.create({
  :title => "○○○○○○○",
  :url => "#",
  :sort_no => 30,
  :web_state => "public",
  :parent_category_id_0 => "all"
})

new_item = System::LinkBanner.new({
:title => "徳島県総合地図提供システム",
:url => "http://maps.pref.tokushima.jp/",
:sort_no =>   10,
:web_state => "public",
:parent_category_id_0 => "all"
})
new_item.save(:validate => false)
banner_file_path = %Q(#{Rails.root.to_s}/db/seed/demo/img/bn_tokushimapref-gis.gif)
banner_file_name = "bn_tokushimapref-gis.gif"
import_photo_data(new_item, "/gis/link/banner/", banner_file_path, banner_file_name)

banner_num = 1
2.times do |i|
  banner_num += i
  new_item = System::LinkBanner.new({
  :title => "○○○○○○○",
  :url => "#",
  :sort_no =>  banner_num * 10,
  :web_state => "public",
  :parent_category_id_0 => "all"
  })
  new_item.save(:validate => false)
  banner_file_path = %Q(#{Rails.root.to_s}/public/_common/themes/gis/images/main/bn-dummy.gif)
  banner_file_name = "bn-dummy.gif"
  import_photo_data(new_item, "/gis/link/banner/", banner_file_path, banner_file_name)

end


System::Option.create({
  :kind => "record_limit",
  :value => 3000
})
System::Option.create({
  :kind => "atom_url",
  :value => "demo,http://demo.joruri.org/shinchaku/index.atom"
})

## gis demo map data


bousai_map_item = Gis::Map.new({
  :state => "enabled",
  :web_state => "public",
  :code => "bousai",
  :title => "防災マップ",
  :message => "<p>防災マップご利用上の注意</p><br />○○○○○○○○○○○○○○○○　○○○○○○○○○○○○○○○○<br />○○○○○○○○○○○○○○○○　○○○○○○○○○○○○○○○○<br />○○○○○○○○○○○○○○○○　○○○○○○○○○○○○○○○○<br />",
  :user_kind => 2,
  :admin_group_id => 5,
  :sort_no => 10,
  :map_legend=> "○○○○○○○○○○○○○○○○　○○○○○○○○○○○○○○○○<br />○○○○○○○○○○○○○○○○　○○○○○○○○○○○○○○○○<br />○○○○○○○○○○○○○○○○　○○○○○○○○○○○○○○○○<br />",
  :body => "○○○○○○○○○○○○○○○○\n○○○○○○○○○○○○○○○○○○○○○○○○○○○○○○○○",
  :is_recommend => 1,
  :portal_kind => 2,
  :parent_category_id => "bousai",
  :parent_category_id_1 => "kurashi",
  :parent_category_id_2 => "gyoseimachizukuri"
})
bousai_map_item.save(:validate=>false)



school_map_item = Gis::Map.new({
  :state => "enabled",
  :web_state => "public",
  :code => "school",
  :title => "学校マップ",
  :message => "<p>学校マップご利用上の注意</p><br />○○○○○○○○○○○○○○○○　○○○○○○○○○○○○○○○○<br />○○○○○○○○○○○○○○○○　○○○○○○○○○○○○○○○○<br />○○○○○○○○○○○○○○○○　○○○○○○○○○○○○○○○○<br />",
  :user_kind => 2,
  :admin_group_id => 5,
  :sort_no => 20,
  :map_legend=> "○○○○○○○○○○○○○○○○　○○○○○○○○○○○○○○○○<br />○○○○○○○○○○○○○○○○　○○○○○○○○○○○○○○○○<br />○○○○○○○○○○○○○○○○　○○○○○○○○○○○○○○○○<br />",
  :body => "○○○○○○○○○○○○○○○○\n○○○○○○○○○○○○○○○○○○○○○○○○○○○○○○○○",
  :is_recommend => 1,
  :portal_kind => 2,
  :parent_category_id => "kyouikubunka",
  :parent_category_id_1 => "kurashi",
  :parent_category_id_2 => "gyoseimachizukuri"
})
school_map_item.save(:validate=>false)



kanko_map_item = Gis::Map.new({
  :state => "enabled",
  :web_state => "public",
  :code => "tourism",
  :title => "観光マップ",
  :message => "<p>観光マップご利用上の注意</p><br />○○○○○○○○○○○○○○○○　○○○○○○○○○○○○○○○○<br />○○○○○○○○○○○○○○○○　○○○○○○○○○○○○○○○○<br />○○○○○○○○○○○○○○○○　○○○○○○○○○○○○○○○○<br />",
  :user_kind => 2,
  :admin_group_id => 5,
  :sort_no => 30,
  :map_legend=> "○○○○○○○○○○○○○○○○　○○○○○○○○○○○○○○○○<br />○○○○○○○○○○○○○○○○　○○○○○○○○○○○○○○○○<br />○○○○○○○○○○○○○○○○　○○○○○○○○○○○○○○○○<br />",
  :body => "○○○○○○○○○○○○○○○○\n○○○○○○○○○○○○○○○○○○○○○○○○○○○○○○○○",
  :is_recommend => 1,
  :portal_kind => 1,
  :parent_category_id => "kanko",
  :parent_category_id_1 => "sangyoshigoto",
  :parent_category_id_2 => "kyouikubunka"
})
kanko_map_item.save(:validate=>false)

thumb_file_path = %Q(#{Rails.root.to_s}/db/seed/demo/img/thumbnail_03.jpg)
thumb_file_name = "thumbnail_03.jpg"
import_map_thumnail(school_map_item, "/gis/portal/thumb/", thumb_file_path, thumb_file_name)

thumb_file_path = %Q(#{Rails.root.to_s}/db/seed/demo/img/thumbnail_02.jpg)
thumb_file_name = "thumbnail_02.jpg"
import_map_thumnail(kanko_map_item, "/gis/portal/thumb/", thumb_file_path, thumb_file_name)

thumb_file_path = %Q(#{Rails.root.to_s}/db/seed/demo/img/thumbnail_01.jpg)
thumb_file_name = "thumbnail_01.jpg"
import_map_thumnail(bousai_map_item, "/gis/portal/thumb/", thumb_file_path, thumb_file_name)


category_num = 0
10.times do |i|
  Gis::Map.create({
    :state => "enabled",
    :web_state => "public",
    :code => "test_#{i}",
    :title => "○○○○○○○",
    :message => "<p>○○○○○○ご利用上の注意</p><br />○○○○○○○○○○○○○○○○　○○○○○○○○○○○○○○○○<br />○○○○○○○○○○○○○○○○　○○○○○○○○○○○○○○○○<br />○○○○○○○○○○○○○○○○　○○○○○○○○○○○○○○○○<br />",
    :user_kind => 2,
    :admin_group_id => 5,
    :sort_no => 40 + i * 10,
    :map_legend=> "○○○○○○○○○○○○○○○○　○○○○○○○○○○○○○○○○<br />○○○○○○○○○○○○○○○○　○○○○○○○○○○○○○○○○<br />○○○○○○○○○○○○○○○○　○○○○○○○○○○○○○○○○<br />",
    :body => "○○○○○○○○○○○○○○○○\n○○○○○○○○○○○○○○○○○○○○○○○○○○○○○○○○",
    :is_recommend => 0,
    :portal_kind => 3,
    :link_url => "#",
    :parent_category_id => category_list[category_num][1]
  })
  category_num += 1
  category_num = 0 if category_num >= 7
end

Gis::Layer.create({
  :state => "enabled",
  :public_state => "all",
  :code => "kindergirden",
  :title => "幼稚園",
  :kind => "vector",
  :is_internal => 1,
  :mapfile_id => 1,
  :mapfile_layer_name => "vector_layer",
  :user_kind => 2,
  :admin_group_id => 5,
  :layer_legend=> "○○○○○○○○○○○○○○○○　○○○○○○○○○○○○○○○○<br />○○○○○○○○○○○○○○○○　○○○○○○○○○○○○○○○○<br />○○○○○○○○○○○○○○○○　○○○○○○○○○○○○○○○○<br />"
})

Gis::LayerDataColumn.create({
  :layer_id => 1,
  :input_fld_1 => "郵便番号",
  :input_fld_2 => "電話番号",
  :input_fld_3 => "設置者",
  :show_fld => "1,2,3"
})

Gis::Layer.create({
  :state => "enabled",
  :public_state => "all",
  :code => "elementary_school",
  :title => "小学校",
  :kind => "vector",
  :is_internal => 1,
  :mapfile_id => 1,
  :mapfile_layer_name => "vector_layer",
  :user_kind => 2,
  :admin_group_id => 5,
  :layer_legend=> "○○○○○○○○○○○○○○○○　○○○○○○○○○○○○○○○○<br />○○○○○○○○○○○○○○○○　○○○○○○○○○○○○○○○○<br />○○○○○○○○○○○○○○○○　○○○○○○○○○○○○○○○○<br />"
})

Gis::LayerDataColumn.create({
  :layer_id => 2,
  :input_fld_1 => "郵便番号",
  :input_fld_2 => "電話番号",
  :input_fld_3 => "設置者",
  :show_fld => "1,2,3"
})


Gis::Layer.create({
  :state => "enabled",
  :public_state => "all",
  :code => "junior_high_school",
  :title => "中学校",
  :kind => "vector",
  :is_internal => 1,
  :mapfile_id => 1,
  :mapfile_layer_name => "vector_layer",
  :user_kind => 2,
  :admin_group_id => 5,
  :layer_legend=> "○○○○○○○○○○○○○○○○　○○○○○○○○○○○○○○○○<br />○○○○○○○○○○○○○○○○　○○○○○○○○○○○○○○○○<br />○○○○○○○○○○○○○○○○　○○○○○○○○○○○○○○○○<br />"
})

Gis::LayerDataColumn.create({
  :layer_id => 3,
  :input_fld_1 => "設置者",
  :input_fld_2 => "電話番号",
  :input_fld_3 => "郵便番号",
  :show_fld => "input_fld1,input_fld2,input_fld3"
})

Gis::Layer.create({
  :state => "enabled",
  :public_state => "all",
  :code => "high_school",
  :title => "高等学校",
  :kind => "vector",
  :is_internal => 1,
  :mapfile_id => 1,
  :mapfile_layer_name => "vector_layer",
  :user_kind => 2,
  :admin_group_id => 5,
  :layer_legend=> "○○○○○○○○○○○○○○○○　○○○○○○○○○○○○○○○○<br />○○○○○○○○○○○○○○○○　○○○○○○○○○○○○○○○○<br />○○○○○○○○○○○○○○○○　○○○○○○○○○○○○○○○○<br />"
})

Gis::LayerDataColumn.create({
  :layer_id => 4,
  :input_fld_1 => "設置者",
  :input_fld_2 => "郵便番号",
  :input_fld_3 => "電話番号",
  :input_fld_4 => "ホームページ",
  :show_fld => "1,2,3,4"
})


Gis::Layer.create({
  :state => "enabled",
  :public_state => "all",
  :code => "tourism_spots",
  :title => "観光スポット",
  :kind => "vector",
  :is_internal => 1,
  :mapfile_id => 1,
  :mapfile_layer_name => "vector_layer",
  :user_kind => 2,
  :admin_group_id => 5,
  :layer_legend=> "○○○○○○○○○○○○○○○○　○○○○○○○○○○○○○○○○<br />○○○○○○○○○○○○○○○○　○○○○○○○○○○○○○○○○<br />○○○○○○○○○○○○○○○○　○○○○○○○○○○○○○○○○<br />"
})

Gis::LayerDataColumn.create({
  :layer_id => 5,
  :input_fld_1 => "電話番号",
  :input_fld_2 => "ホームページ",
  :input_fld_3 => "カテゴリ",
  :input_fld_4 => "地区",
  :show_fld => "1,2,3,4"
})
import_layer_csv("01_kindergirden.csv",1, 39)
import_layer_csv("02_elementary_school.csv",2, 40)
import_layer_csv("03_junior_high_school.csv",3, 41)
import_layer_csv("04_high_school.csv",4, 42)
import_layer_csv("tourism_map.csv",5, 39)

spot = Gis::LayerDatum.where(:name => "祖谷のかずら橋", :layer_id => 5).first

if spot
  spot_photo = Gis::LayerDataPhoto.new({
    :web_state => "public",
    :sort_no => 10,
    :caption => "かずら橋",
    :layer_id => 5,
    :layer_data_id => spot.rid
  })
  spot_photo.save(:validate=>false)
  spot_photo_path = %Q(#{Rails.root.to_s}/db/seed/demo/DSC_0132.jpg)
  spot_photo_name = "DSC_0132.jpg"
  upload_path = import_photo_data(spot_photo, "/upload/gis/facility/#{spot.rid}/", spot_photo_path, spot_photo_name,true,true)
  spot_photo.original_file_uri = spot_photo.file_uri
  spot_photo.original_file_path = spot_photo.file_path

    if spot_photo.width > 1600 || spot_photo.height > 1200
      resized_size = spot_photo.reduce(upload_path[0],1600,1200)
      spot_photo.width = resized_size[0]
      spot_photo.height = resized_size[1]
      spot_photo.size = resized_size[2]
    end

  reduce_path = spot_photo.resize(upload_path[0],spot_photo.original_file_path,640,480,"reduce")
  if reduce_path
    spot_photo.file_path = reduce_path
    spot_photo.file_uri= %Q(#{upload_path[1]}#{upload_path[2]})
  end
  thumb_path = spot_photo.resize(upload_path[0],spot_photo.original_file_path,240,180,"thumb")
  if thumb_path
    spot_photo.thumb_file_path = thumb_path
    spot_photo.thumb_file_uri= %Q(#{upload_path[1]}#{upload_path[2]})
  end
  spot_photo.save(:validate=>false)

end

Gis::Assortment.create({
  :title=>"公立学校",
  :sort_no => 10,
  :user_kind => 2,
  :admin_group_id => 5,
  :web_state => "all"
})

Gis::AssortmentsLayer.create({
  :assortment_id => 1,
  :layer_id => 1,
  :sort_no => 10
})
Gis::AssortmentsLayer.create({
  :assortment_id => 1,
  :layer_id => 2,
  :sort_no => 20
})
Gis::AssortmentsLayer.create({
  :assortment_id => 1,
  :layer_id => 3,
  :sort_no => 30
})
Gis::AssortmentsLayer.create({
  :assortment_id => 1,
  :layer_id => 4,
  :sort_no => 40
})

Gis::MapsAssortment.create({
  :assortment_id => 1,
  :map_id => 1,
  :sort_no => 20
})

Gis::MapsAssortment.create({
  :assortment_id => 1,
  :map_id => 2,
  :sort_no => 10
})

Gis::MapsLayer.create({
  :layer_id => 5,
  :map_id => 3,
  :sort_no => 10
})


filepath = %Q(#{Rails.root.to_s}/db/seed/demo/A26-10_36_GML/A26-10_36-g_SedimentDisasterHazardArea_Surface.shp)
import_shapfile_data("landslide","土砂災害",4612,filepath,"polygon","input_fld_1","rgb(0, 0, 0)","rgb(255, 0, 0)","rgb(0, 0, 0)","rgb(255, 0, 0)", 1.0 )

filepath = %Q(#{Rails.root.to_s}/db/seed/demo/A30b-11_GML/AppearancePoint_Gust.shp)
import_shapfile_data("gust_appear","竜巻-発生箇所",4612,filepath,"point","input_fld_7","rgb(0, 0, 0)","rgb(255, 0, 0)",nil,nil,nil )

filepath = %Q(#{Rails.root.to_s}/db/seed/demo/A30b-11_GML/DisappearancePoint_Gust.shp)
import_shapfile_data("gust_disappear","竜巻-消滅箇所",4612,filepath,"point","input_fld_7","rgb(0, 0, 0)","rgb(0, 0, 255)",nil,nil ,nil)

Gis::Assortment.create({
  :title=>"ハザードマップ",
  :sort_no => 20,
  :user_kind => 2,
  :admin_group_id => 5,
  :web_state => "all"
})

Gis::AssortmentsLayer.create({
  :assortment_id => 2,
  :layer_id => 6,
  :sort_no => 10
})
Gis::AssortmentsLayer.create({
  :assortment_id => 2,
  :layer_id => 7,
  :sort_no => 20
})
Gis::AssortmentsLayer.create({
  :assortment_id => 2,
  :layer_id => 8,
  :sort_no => 30
})

Gis::MapsAssortment.create({
  :assortment_id => 2,
  :map_id => 1,
  :sort_no => 10
})


filepath = %Q(#{Rails.root.to_s}/db/seed/demo/A27-10_36-g/A27-10_36-g_SchoolDistrict.shp)
import_shapfile_data("school_area","小学校区",4612,filepath,"polygon","input_fld_3","rgb(0, 0, 0)","rgb(0, 0, 255)","rgb(255, 0, 0)","rgb(255, 255, 255)" ,2.0)


Gis::AssortmentsLayer.create({
  :assortment_id => 1,
  :layer_id => 9,
  :sort_no => 50
})



Misc::SearchColumn.create({
  :portal_id => 3,
  :label => "市町村",
  :form_type => "area",
  :sort_no => 10,
})

Misc::SearchColumn.create({
  :portal_id => 3,
  :label => "名称",
  :form_type => "text",
  :sort_no => 20,
  :column_flds => [
    [5, "name"]
  ]
})

ind_portal_photo = Misc::PortalPhoto.new({
  :portal_id => 3,
  :sort_no => 10,
  :web_state => "public",
  :title => "観光マップメインビジュアル",
  :caption => "観光マップ",
})

ind_portal_photo.save(:validate => false)
portal_photo_path = %Q(#{Rails.root.to_s}/db/seed/demo/tourism_map.jpg)
portal_photo_name = "tourism_map.jpg"
import_photo_data(ind_portal_photo, "/gis/portal/photo/", portal_photo_path, portal_photo_name)

Misc::SocialUpdate.create({
  :map_id => 3,
  :web_state => "public",
  :title => "観光マップを公開しました！",
  :body =>  "○○○○○○○○○○○○○○○○　○○○○○○○○○○○○○○○○<br />○○○○○○○○○○○○○○○○　○○○○○○○○○○○○○○○○<br />○○○○○○○○○○○○○○○○　○○○○○○○○○○○○○○○○<br />",
  :published_at => Time.now,
  :inquiry_group_id => 5,
  :mail_to => "jorurimaps@demo.joruri.org",
  :tel => "（0000）00-0000",
  :fax => "（0000）00-0000 "
})
4.times do |i|
  Misc::SocialUpdate.create({
    :map_id => 3,
    :web_state => "public",
    :title => "サンプルマップ○○○○○○○○○○○を公開しました！",
    :body =>  "○○○○○○○○○○○○○○○○　○○○○○○○○○○○○○○○○<br />○○○○○○○○○○○○○○○○　○○○○○○○○○○○○○○○○<br />○○○○○○○○○○○○○○○○　○○○○○○○○○○○○○○○○<br />",
    :published_at => Time.now,
    :inquiry_group_id => 5,
    :mail_to => "jorurimaps@demo.joruri.org",
    :tel => "（0000）00-0000",
    :fax => "（0000）00-0000 "
  })
end
4.times do |i|
  Misc::PortalRecommend.create({
    :portal_id => 3,
    :web_state => "public",
    :title => "○○○○○○○○○",
    :sort_no => i * 10,
    :url => "?mode=recommend&s_area_code=&s_custom_field_2=",
    :column_flds => ["s_custom_field_2", nil]
  })
  Misc::PortalLink.create({
    :portal_id => 3,
    :title => "○○○○○○○○○",
    :url => "#",
    :web_state => "public",
    :sort_no => i * 10
  })
end

Misc::Inquiry.create({
  :portal_id=>3,
  :sort_no => 10,
  :inquiry_group_id => 5,
  :mail_to => "jorurimaps@demo.joruri.org",
  :tel => "（0000）00-0000",
  :fax => "（0000）00-0000 "
})

Misc::Script::Feed.import_rss

Rails.cache.clear

puts "Imported demo data."
