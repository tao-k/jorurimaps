# encoding: utf-8
class Gis::LayerFile < ActiveRecord::Base
  include Sys::Model::Base::Config
  include System::Model::Base
  include System::Model::Operator
  include System::Model::FileUtil
  include Gis::Script::Import::Shape

  after_destroy :destroy_file
  belongs_to :layer, :class_name => "Gis::Layer"

  def upload_shape_directory
    upload_path = Rails.root.to_s
    upload_path += '/' unless upload_path.ends_with?('/')
    upload_path += "/upload/gis/layer/#{self.layer_id}/"
    return upload_path
  end

  def save_with_layer(layer_id, file=nil,set_srid=nil)
    self.layer_id = layer_id
    self.srid = set_srid
    return false if self.layer.blank?
    return true if self.layer.kind != "gpx" && self.layer.kind != "kml" && self.layer.kind != "file"
    return false if file.blank?
    upload_file = file.read
    self.content_type = file.content_type
    original_file_name = file.original_filename # ファイル名
    extname = File.extname(original_file_name) # 拡張子を抽出
    extname_judges = [self.layer.kind]
    extname_judges << "zip" if self.layer.kind == "file"
    is_valid_file = true
    is_valid_file = false if extname_judges.index(extname.downcase).blank? # downcase：小文字に揃える、index：配列を検索
    directory = "/gis/layer/"
    self.kind = self.layer.kind
    self.original_file_name = original_file_name
    file_name = "#{format('%08d', self.layer_id)}#{extname}"
    upload_path = Rails.root.to_s
    upload_path += '/' unless upload_path.ends_with?('/')
    upload_path += "upload#{directory}#{file_name}"
    self.file_uri = %Q(/gis/layer_file/#{file_name})
    self.file_path = "/upload#{directory}#{file_name}"
    self.mkdir_for_file(upload_path)
    mkdir_for_file(upload_path)
    File.delete(upload_path) if File.exist?(upload_path)
    File.open(upload_path, 'wb') { |f|
      f.write upload_file
    }
    self.save

    return self.import_shape_file  if self.layer.kind == "file"
    return true
  end


  def destroy_file
    begin
      src = "#{Rails.root.to_s}#{self.file_path}"
      FileUtils.rm_rf(src)
      src_filename = src.gsub(/.*(\.\w{3}$)/iom, '\1')
      thumb_src = "#{src.gsub(/(\.\w{3}$)/,"")}_thumb#{src_filename}"
      FileUtils.rm_rf(thumb_src)
      FileUtils.rm_rf(upload_shape_directory)
    rescue => e
      dump e
    end
  end


end
