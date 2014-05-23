# encoding: utf-8

## ---------------------------------------------------------
## methods

def truncate_table(table)
  puts "TRUNCATE TABLE #{table}"
  ActiveRecord::Base.connection.execute "TRUNCATE TABLE #{table}"
end

def reset_sequence(table)
  puts "ALTER SEQUENCE #{table} restart with 1;"
  ActiveRecord::Base.connection.execute "ALTER SEQUENCE #{table} restart with 1;"
end

def load_seed_file(file)
  load "#{Rails.root}/db/seed/#{file}"
end

## ---------------------------------------------------------
## truncate

dir = "#{Rails.root}/db/seed/base"
Dir::entries(dir).each do |file|
  next if file !~ /\.rb$/
  load_seed_file "base/#{file}"
end

## ---------------------------------------------------------
## load config

core_uri   = Util::Config.load :core, :uri
core_title = Util::Config.load :core, :title

## ---------------------------------------------------------
## sys

System::Group.create({
  :parent_id => 0,
  :level_no  => 1,
  :sort_no   => 1,
  :state     => 'enabled',
  :ldap      => 0,
  :code      => "1",
  :name      => "ジョールリ市",
  :name_en   => "soshiki",
  :start_at  => Time.now
})

System::Group.create({
  :level_no  => 2,
  :sort_no   => 1,
  :parent_id => 1,
  :state     => 'enabled',
  :ldap      => 0,
  :code      => "000",
  :name      => "システム管理部",
  :name_en   => "sisutemkanri",
  :start_at  => Time.now
})

System::Group.create({
  :level_no  => 3,
  :sort_no   => 1,
  :parent_id => 2,
  :state     => 'enabled',
  :ldap      => 0,
  :code      => "000001",
  :name      => "管理課",
  :name_en   => "kanrika",
  :start_at  => Time.now
})
System::User.create({
  :state    => 'enabled',
  :ldap     => 0,
  :auth_no  => 5,
  :name     => "システム管理者",
  :account  => "admin",
  :code     => "admin",
  :password => "admin"
})

System::UsersGroup.create({
  :user_id  => 1,
  :group_id => 3,
  :start_at  => Time.now
})

System::User.create({
  :state    => 'enabled',
  :ldap     => 0,
  :auth_no  => 4,
  :name     => "承認管理者",
  :account  => "recognizer",
  :code     => "recognizer",
  :password => "recognizer"
})

System::UsersGroup.create({
  :user_id  => 2,
  :group_id => 3,
  :start_at  => Time.now
})
System::User.create({
  :state    => 'enabled',
  :ldap     => 0,
  :auth_no  => 3,
  :name     => "一般ユーザ",
  :account  => "user1",
  :code     => "user1",
  :password => "user1"
})

System::UsersGroup.create({
  :user_id  => 3,
  :group_id => 3,
  :start_at  => Time.now
})


Core.user       = System::User.where(:account => 'admin').first
Core.user_group = Core.user.groups[0]

## ---------------------------------------------------------
## gis

mapfile_body = ""
mapfile_tpl = %Q(#{Rails.root.to_s}/template/point_data_layer.tpl)
if  File.exist?(mapfile_tpl)
  File::open(mapfile_tpl) {|f|
    mapfile_body = f.read
  }

  new_item = Gis::Mapfile.new({
    :file_name => "point_data_layer.map",
    :title => "ポイントデータ用マップファイル",
    :caption => "種別：ポイントデータ　のレイヤーの表示用マップファイルです。システムにより自動生成されます。",
    :is_vector_mapfile => 1,
    :body => mapfile_body,
    :user_kind => 2,
    :admin_group_id => 3,
    :state => "enabled"
  })
  new_item.save
end
template_body = ""
tamplate_tpl = %Q(#{Rails.root.to_s}/template/point_data_layer_tmpl.tpl)
if  File.exist?(tamplate_tpl)
  File::open(tamplate_tpl) {|f|
    template_body = f.read
  }

  new_item = Gis::Mapfile.create({
    :file_name => "templates/json_point_layer.tmpl",
    :title => "ポイントデータ用マップファイル-テンプレート",
    :caption => "種別：ポイントデータ　のレイヤーの表示用テンプレートです。システムにより自動生成されます。",
    :is_vector_mapfile => 1,
    :body => template_body,
    :user_kind => 2,
    :admin_group_id => 3,
    :state => "enabled"
  })
  new_item.save
end

Gis::BackgroundMap.create({
  :state   => "public",
  :code    => "webtis_monotone",
  :title   => "基盤地図淡色（地理院地図）",
  :kind    => "webtis_monotone",
  :sort_no => 10
})

Gis::BackgroundMap.create({
  :state   => "public",
  :code    => "webtis_basic",
  :title   => "基盤地図（地理院地図）",
  :kind    => "webtis_normal",
  :sort_no => 20
})

Gis::BackgroundMap.create({
  :state   => "public",
  :code    => "gmap",
  :title   => "グーグルマップ",
  :kind    => "gmap",
  :sort_no => 30
})


Gis::BackgroundMap.create({
  :state   => "public",
  :code    => "gmap",
  :title   => "グーグルマップ（道路）",
  :kind    => "gmap",
  :sort_no => 30
})


Gis::BackgroundMap.create({
  :state   => "public",
  :code    => "gsat",
  :title   => "グーグルマップ(衛星)",
  :kind    => "gsat",
  :sort_no => 30
})

Gis::BackgroundMap.create({
  :state   => "public",
  :code    => "g_hybrid",
  :title   => "グーグルマップ（衛星＆道路）",
  :kind    => "g_hybrid",
  :sort_no => 30
})
Gis::BackgroundMap.create({
  :state   => "public",
  :code    => "osm",
  :title   => "オープンストリートマップ",
  :kind    => "osm",
  :sort_no => 30
})

require 'csv'
icon_list_csv =  %Q(#{Rails.root.to_s}/db/map_icon.csv)
if  File.exist?(icon_list_csv)
  csv = ""
  File::open(icon_list_csv) {|f|
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
        original_file_path = ""
        row.each_with_index{|row_item, i|
          next if row_item.blank?
          next if columns[i].blank?
          if  columns[i] == "file_path"
            original_file_path = %Q(#{Rails.root.to_s}/public/)
            original_file_path += row_item
          else
            data[columns[i].to_sym] = row_item
          end

        }
        if data
            new_item = Gis::MapIcon.new
            new_item.attributes = data
            new_item.save(:validate=>false)
            if File.exist?(original_file_path)
              upload_file = nil
                File::open(original_file_path) {|f|
                  upload_file =  f.read
                }
                if upload_file
                  tmp_id = new_item.id.to_s
                  dir = tmp_id.gsub(/(.*)(..)(..)(..)$/, '\1/\2/\3/\4/\1\2\3\4')
                  directory = "/gis/map/icon/#{dir}/"
                   extname = File.extname(data[:original_file_name])
                  file_name = "#{format('%08d', new_item.id.to_s)}#{extname}"
                  upload_path = Rails.root.to_s
                  upload_path += '/' unless upload_path.ends_with?('/')
                  upload_path += "public#{directory}#{file_name}"
                  new_item.file_uri = %Q(#{directory}#{file_name})
                  new_item.file_path = "/public#{directory}#{file_name}"
                  new_item.mkdir_for_file(upload_path)
                  File.open(upload_path, 'wb') { |f|
                    f.write upload_file
                  }
                end
              new_item.save(:validate=>false)
            end

        end
      end
    end
  end
end

puts "Imported base data."
