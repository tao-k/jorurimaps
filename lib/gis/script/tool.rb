# -*- encoding: utf-8 -*-
require 'csv'
require 'zipruby'
require 'RMagick'
class Gis::Script::Tool

  def self.import_gis_table_configs
    filepath = "#{Rails.root.to_s}/upload/gis_tables.csv"
    csv = ""
    if File.exist?(filepath)
      File.open(filepath) do |data|
        csv = NKF.nkf('-w', data.read)
      end
    end
    return if csv.blank?
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
          new_item = Gis::LayerImportConfig.new
          new_item.attributes = data
          new_item.save
        end
      end
    end

  end

  def self.make_ruby_html
    directories = [
      "#{Rails.root.to_s}/public/options/"
    ]
    directories.each do |directory|
      Dir::entries(directory).sort.each do |name|
        if name =~ /\.html$/
          filepath =  "#{directory}#{name}"
          csv = nil
          if File.exist?(filepath)
            File.open(filepath) do |data|
              csv = NKF.nkf('-w', data.read)
            end
          end
          next if csv.blank?
          original_body = csv
          res_body = original_body.gsub(/(.*)(<body[^>]*>.*<\/body>)(.*)/im, '\2')
          res_body = Cms::Lib::Navi::Ruby.convert(res_body)
          ret  = original_body.gsub(/<body[^>]*>.*<\/body>/im, res_body)
          make_html(ret, name, directory)
        end
      end
    end
  end

  def self.make_html(body, filename, directory)
    upload_path = "#{directory}#{filename}.r"
    File.delete(upload_path) if File.exist?(upload_path)
    File.open(upload_path, 'wb') { |f|
      f.write body
    }
  end


  def self.mkdir_for_file(path)
    mode_file = !path.ends_with?('/')
    px = path.split(/\//)
    dir_name = px[0, px.length - (mode_file ? 1 : 0)].join(File::Separator)
    ret = true
    begin
      FileUtils.mkdir_p(dir_name) unless File.exist?(dir_name)
    rescue
      ret = false
    end
    return ret
  end


  def self.export_csv(params, layer,options={})
    item = Gis::LayerDatum.new#.readable
    item.and :layer_id, layer.id
    item.order params[:sort], "updated_at desc"
    items = item.find(:all)
    columns_confs = layer.get_column_settings({:export=>true})
    columns_names = []
    columns_header = []
    columns_confs.each{|val|
      columns_header << val[1]
      columns_names << [val[0], val[1]]
    }
    if items.blank?
      return "NODATA"
    else
      begin
        csv_string = CSV.generate("", {:encoding => 'sjis',:force_quotes => true}) do |csv|
          csv << columns_header
          items.each do |m|
            record_set = []
            public_photos = m.get_public_photos(10)
            columns_names.each {|column|

              if column[0] =~ /photo/
                if public_photos.blank?
                  record_set << ""
                  next
                end
                photo_count = column[0].gsub(/photo/,"").to_i - 1
                if public_photos[photo_count]
                  #record_set << %Q(#{options[:url]}#{public_photos[photo_count].public_photo_path})
                  record_set << %Q(#{public_photos[photo_count].original_file_name})
                else
                  record_set << ""
                end
              else
                record_set << eval("m.#{column[0]}")
              end
            }
            csv << record_set
          end
        end
        #IE判定
        csv_string = csv_string.tosjis
        return csv_string
      rescue => e
        dump e
        return nil
      end
    end
  end



  def self.import_form_csv(params, layer,count=0)
    columns_confs = layer.get_column_with_photo_settings
    columns = []
    csv = NKF.nkf('-w', params[:item][:file].read)

    begin
      CSV.parse(csv) do |row|
        if columns.blank?
          row.each do |row_item|
            columns_confs.each do  |column_item|
              columns << column_item[0] if column_item[1] == row_item
            end
          end
        else
          data = {}
          row.each_with_index{|row_item, i|
            next if row_item.blank?
            next if columns[i].blank?
            data[columns[i].to_sym] = row_item
          }
          if data
            10.times{|i|
              data.delete("photo#{i}".to_sym) if data["photo#{i}".to_sym]
            }
            if data[:id]
              item = Gis::LayerDatum.where(:rid => data[:id], :layer_id => layer.id).first || Gis::LayerDatum.new
              data.delete(:id)
              for num in 1..50 do
                column_sym = "input_fld_#{num}".to_sym
                data[column_sym] = nil
              end
            else
              item = Gis::LayerDatum.new
            end
            item.layer_id = layer.id
            item.state = "enabled"
            if data[:web_state_show]
              item.web_state = "closed"
              item.web_state = "public" if data[:web_state_show] == "公開"
              data.delete(:web_state_show)
            end
            if data[:icon_kind]
              icon = Gis::MapIcon.where(:title => data[:icon_kind]).first
              item.icon_id = icon.id if icon
              data.delete(:icon_kind)
            end
            if data[:area_show]
              area = System::City.where(:name => data[:area_show]).first
              item.area_code = area.rid if area
              data.delete(:area_show)
            end
            if data[:lat].blank? && data[:lng].blank?
              lat_lng = parse_lat_lng(data[:address])
              unless lat_lng.blank?
                item.lat = lat_lng[:lat]
                item.lng = lat_lng[:lng]
              end
            end
            item.attributes = data
            item.save(:validate => false)
            count+=1
          end
        end
      end
      return {:result=> true, :count=>count}
    rescue => e
      dump e
      return {:result=> false, :count=>count}
    end
  end

  def self.import_photos_from_csv(params, layer,count=0)
    directory = "upload/gis/import/#{format('%08d', layer.id)}/"
    file_name = "#{Time.now.to_i}.zip"
    upload_path = Rails.root.to_s
    upload_path += '/' unless upload_path.ends_with?('/')
    zip_upload_path = "#{upload_path}#{directory}#{file_name}"
    mkdir_for_file(zip_upload_path)
    File.delete(zip_upload_path) if File.exist?(zip_upload_path)
    File.open(zip_upload_path, 'wb') { |f|
      f.write params[:item][:file].read
    }
    begin
      columns_confs = layer.get_column_with_photo_settings
      columns = []
      csv = ""
      file_name_list = []
      Zip::Archive.open(zip_upload_path) do |ar|
        dir_name = []
        ar.each_with_index do |zf, n|
          if zf.directory?
            dir_name << zf.name.encode("UTF-8",{:invalid => :replace,:undef => :replace, :replace =>"_"}).gsub("\\", "/")
          else
            entry_name = zf.name.encode("UTF-8",{:invalid => :replace,:undef => :replace, :replace =>"_"}).gsub("\\", "/")
            unless dir_name.blank?
              dir_name.each do |dir|
                entry_name = entry_name.gsub(dir,"")
              end
            end
            entry_name = entry_name.downcase
            entry_name = entry_name.gsub(/.*\//,"")
            extname = File.extname(entry_name).downcase
            if extname =~ /.csv/
              csv = NKF.nkf('-w', zf.read)
            else
              file_name = "#{Time.now.to_i}_#{n}#{extname}"
              file_upload_path = "#{upload_path}#{directory}#{file_name}"
              mkdir_for_file(file_upload_path)
              File.delete(file_upload_path) if File.exist?(file_upload_path)
              open(file_upload_path, 'wb') do |f|
                f << zf.read
              end
              file_name_list << {:original_file_name => entry_name, :upload_path => file_upload_path, :file_path => "/#{directory}#{file_name}"}
            end
          end
        end
      end

      photo_id_set = {}
      CSV.parse(csv) do |row|
        if columns.blank?
          row.each do |row_item|
            columns_confs.each do  |column_item|
              columns << column_item[0] if column_item[1] == row_item
            end
          end
        else
          data = {}
          row.each_with_index{|row_item, i|
            next if row_item.blank?
            next if columns[i].blank?
            data[columns[i].to_sym] = row_item
          }
          if data
            photo_array = []
            if data[:id]
              item = Gis::LayerDatum.where(:rid => data[:id], :layer_id => layer.id).first || Gis::LayerDatum.new
              data.delete(:id)
              for num in 1..50 do
                column_sym = "input_fld_#{num}".to_sym
                data[column_sym] = nil
              end
            else
              item = Gis::LayerDatum.new
            end
            item.layer_id = layer.id
            item.state = "enabled"
            item.web_state = "closed"
            if data[:web_state_show]
              item.web_state = "public" if data[:web_state_show] == "公開"
              data.delete(:web_state_show)
            end
            if data[:icon_kind]
              icon = Gis::MapIcon.where(:title => data[:icon_kind]).first
              item.icon_id = icon.id if icon
              data.delete(:icon_kind)
            end
            if data[:area_show]
              area = System::City.where(:name => data[:area_show]).first
              item.area_code = area.rid if area
              data.delete(:area_show)
            end
            if data[:photo1]
              photo_array << data[:photo1]
              data.delete(:photo1)
            end
            if data[:photo2]
              photo_array << data[:photo2]
              data.delete(:photo2)
            end
            if data[:photo3]
              photo_array << data[:photo3]
              data.delete(:photo3)
            end
            if data[:photo4]
              photo_array << data[:phot04]
              data.delete(:photo04)
            end
            if data[:photo5]
              photo_array << data[:photo5]
              data.delete(:photo5)
            end
            if data[:photo6]
              photo_array << data[:photo6]
              data.delete(:photo6)
            end
            if data[:photo7]
              photo_array << data[:photo7]
              data.delete(:photo7)
            end
            if data[:photo8]
              photo_array << data[:photo8]
              data.delete(:photo8)
            end
            if data[:photo9]
              photo_array << data[:photo9]
              data.delete(:photo9)
            end
            if data[:photo10]
              photo_array << data[:photo10]
              data.delete(:photo10)
            end
            item.attributes = data
            if data[:lat].blank? && data[:lng].blank?
              lat_lng = parse_lat_lng(data[:address])
              unless lat_lng.blank?
                item.lat = lat_lng[:lat]
                item.lng = lat_lng[:lng]
              end
            end
            item.save(:validate => false)
            count+=1
            photo_array.each do |photo_name|
              photo_name = photo_name.downcase
              photo_id_set[photo_name] = item.rid
            end unless photo_array.blank?
          end
        end
      end

      file_sort = {}
      file_name_list.each do |tmp_file|
        file_conf = photo_id_set[tmp_file[:original_file_name]]
        if file_conf
          if file_sort[file_conf]
            file_sort[file_conf] += 10
          else
            file_sort[file_conf] = 10
          end
          item = Gis::LayerDataPhoto.new
          item.layer_data_id = file_conf
          item.layer_id      =  layer.id
          item.original_file_name = tmp_file[:original_file_name]
          item.web_state = "public"
          item.sort_no =  file_sort[file_conf]
          if File.exist?(tmp_file[:upload_path])
            File.open(tmp_file[:upload_path],"r"){|f|
              upload_file = f.read
              upload_photo_size = get_size(upload_file)
              item.width = upload_photo_size[0]
              item.height = upload_photo_size[1]
              item.size = upload_file.size.to_i

            }
            item.original_file_uri = tmp_file[:file_path]
            item.original_file_path = tmp_file[:file_path]


            if item.width > 1600 || item.height > 1200
              resized_size = item.reduce(upload_path,1600,1200)
              item.width = resized_size[0]
              item.height = resized_size[1]
              item.size = resized_size[2]
            end
            reduce_path = item.resize(tmp_file[:upload_path],item.original_file_path,640,480,"reduce")
            if reduce_path
              item.file_path = reduce_path
              item.file_uri= %Q(#{directory}#{file_name})
            end
            thumb_path = item.resize(tmp_file[:upload_path],item.original_file_path,240,180,"thumb")
            if thumb_path
              item.thumb_file_path = thumb_path
              item.thumb_file_uri= %Q(#{directory}#{file_name})
            end
            item.save
          end

          #parse_exif(tmp_file[:file_path], file_conf)
        else
          #
        end
      end

      return {:result=> true, :count=>count}
    rescue => e
      dump $@
      dump e
      return {:result=> false, :count=>count}
    end
  end

  def self.parse_lat_lng(address)
    #住所から緯度経度を取得する
    return nil if address.blank?
    features = Gis::Script::Geocoding.get_point(address)
    return nil if features.blank?
    ret = {:lat =>features[:lat], :lng => features[:lng]}
    return ret
  end

  def self.parse_exif(filepath, data_id)
    #Exif情報から緯度経度を取得後、プロファイルを削除する
    begin
        tags = EXIFR::JPEG.new(filepath)
        ret = nil
        if tags && tags.exif
          #dump tags.to_hash
          latitude = tags.exif[:gps_latitude]
          if latitude
            c_latitude = latitude[0].to_f + latitude[1].to_f/60 + latitude[2].to_f/3600
            c_latitude = c_latitude * -1 if tags.gps_latitude_ref == "S"
          end
          longitude = tags.exif[:gps_longitude]
          if longitude
            c_longitude = longitude[0].to_f + longitude[1].to_f/60 + longitude[2].to_f/3600
            c_longitude = c_longitude * -1 if tags.gps_longitude_ref == "W"
          end
          if data_id
            datum = Gis::LayerDatum.where(:rid => data_id).first
            if datum && datum.lat.blank? && datum.lng.blank?
              datum.lat = c_latitude
              datumn.lng = c_longitude
              datumn.save(:validate=>false)
            end
          end
        end
        #dump ret
        image = Magick::Image.read(filepath).first
        image.profile!("*", nil)
        return ret
      rescue => e
        dump e
      end
  end

  def self.get_size(upload_file)
    begin
      require 'RMagick'
      img = Magick::Image.from_blob(upload_file).shift
      width = img.columns
      height = img.rows
      size = img.filesize
      return [width, height,size]
    rescue
      return [0, 0,0]
    end
  end
end