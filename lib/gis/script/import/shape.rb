# -*- encoding: utf-8 -*-
require 'rgeo/shapefile'
require 'nkf'
require 'zipruby'

module Gis::Script::Import::Shape


  def import_shape_file
    zip_upload_path = %Q(#{Rails.root.to_s}#{self.file_path})
    upload_path = upload_shape_directory
    FileUtils.rm_rf(upload_shape_directory)
    filepath = ""
    current_file_name = Time.now.to_i
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
            extname = File.extname(entry_name).downcase
            file_name = "#{current_file_name}#{extname}"
            file_upload_path = "#{upload_path}#{file_name}"
            mkdir_for_file(file_upload_path)
            File.delete(file_upload_path) if File.exist?(file_upload_path)
            open(file_upload_path, 'wb') do |f|
              f << zf.read
            end
            filepath = file_upload_path if extname =~ /.shp/
          end
      end
    end
    return false if filepath.blank?
    return Gis::Script::Import::Shape.import_data(self.layer, filepath)
  end

  def self.import_data(file_layer, filepath)
    #filepath = shape_path[0]
    fields = []
    Gis::LayerImportDatum.destroy_all(:layer_id => file_layer.id)
    begin
      RGeo::Shapefile::Reader.open(filepath) do |file|
        limit = get_system_option
        if file.num_records >= limit && !Core.user.has_auth?(:manager)
          dump "レコード数が#{limit}件以上のため終了"
          return false
        end

        layer_geometry_type = nil
        file.each do |record|
          geometry_type = record.geometry.as_text.gsub(/\(.*\)/,"")
          unless layer_geometry_type
            layer_geometry_type = case geometry_type
            when /POINT/
              "point"
            when /LINE/
              "line"
            when /POLYGON/
              "polygon"
            else
              "point"
            end
          end
          model = Gis::LayerImportDatum
          new_item = model.new
          new_item.layer_id = file_layer.id
          fields = record.attributes.keys if fields.blank?
          fld_num = 1
          record.attributes.each do |key, value|
            if fld_num <= 50
              value = "#{value}"
              s_value = NKF.nkf('-w', value)
              eval(%Q(new_item.input_fld_#{fld_num} = '#{s_value}'))
            end
            fld_num += 1
          end
          new_item.save(:validate=>false)
          #正常に動作しないので後から挿入
          geom_as_text = record.geometry.as_text
          if geom_as_text.match(/(\d*.\d* \d*.\d* )(\d*.\d* \d*.\d*)(,)?/)
            geom_as_text = geom_as_text.gsub(/(\d*.\d* \d*.\d* )(\d*.\d* \d*.\d*)(,)?/,'\1\3')
          else
            #geom_as_text = record.geometry.as_text
          end
          if file_layer.srid
            begin
              model.update_all("g = ST_Transform(ST_GeomFromText('#{geom_as_text}', #{file_layer.srid}), 4326)", "rid = #{new_item.rid}")
              if geometry_type =~ /POINT/
                model.update_all("lng = ST_X(g)", "rid = #{new_item.rid}")
                model.update_all("lat = ST_Y(g)", "rid = #{new_item.rid}")
              end
            rescue=>e
              dump e
              #model.update_all("g = ST_GeomFromText('#{record.geometry.as_text}',  4326)", "rid = #{new_item.rid}")
            end
          else
            model.update_all("g = ST_GeomFromText('#{geom_as_text}',  4326)", "rid = #{new_item.rid}")
          end
        end
        #地理情報タイプを設定する
        file_layer.update_column("geometry_type" , layer_geometry_type) if layer_geometry_type
        #カラム名を設定する
        column_setting = Gis::LayerDataColumn.where(:layer_id => file_layer.id).first || Gis::LayerDataColumn.new
        column_setting.layer_id = file_layer.id
        fields.each_with_index do |value, i|
          fld_num = i + 1
          eval(%Q(column_setting.input_fld_#{fld_num} = '#{value}'))
        end
        column_setting.save(:validate=>false)
      end
    rescue => e
      dump $@
      dump e
      return false
    end
    return true
  end

  def self.get_system_option
    record_limit = System::Option.where(:kind => "record_limit").first
    return 3000 if record_limit.blank?
    return record_limit.value.to_i
  end

end