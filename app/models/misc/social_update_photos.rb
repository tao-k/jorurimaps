# encoding: utf-8
class Misc::SocialUpdatePhotos < ActiveRecord::Base
  include System::Model::Base
  include System::Model::Base::Config
  include System::Model::Operator
  include System::Model::FileUtil

  after_destroy :destroy_file


  def show_width(set_width=200)
    if self.width > set_width
      ret = set_width
    else
      ret = self.width
    end
    return ret
  end

  def show_height(set_height=50)
    if self.width > set_height
      ret = set_height
    else
      ret = self.width
    end
    return ret
  end


  def save_with_file(par_item, mode=:create)
    return false if par_item.blank?
    file = par_item[:upload]
    if mode==:update && file.blank?
      if self.save
        return true
      else
        return false
      end
    else
      if par_item[:upload].blank?
        self.errors.add(:upload, "を指定してください。")
      end
      return false if file.blank?
      upload_file = file.read
      self.model_name = par_item[:model_name]
      self.size = upload_file.size.to_i
      original_file_name = file.original_filename # ファイル名
      extname = File.extname(original_file_name) # 拡張子を抽出
      extname_judges = [".jpeg", ".jpg", ".png", ".gif"]
      is_valid_imagefile = true
      is_valid_imagefile = false if extname_judges.index(extname.downcase).blank? # downcase：小文字に揃える、index：配列を検索

      if is_valid_imagefile
        upload_photo_size = get_size(upload_file)
        self.errors.add(:upload, "として1MB以上のファイルサイズの画像はアップロードできません。") if upload_photo_size[2] > 1024 * 1024 * 1 if upload_photo_size[2] != 0
        self.width = upload_photo_size[0]
        self.height = upload_photo_size[1]
        self.is_image = 1
      end
      return false if self.errors.size > 0
      if self.save
        directory_id = self.id.to_s
        dir = tmp_id.gsub(/(.*)(..)(..)(..)$/, '\1/\2/\3/\4/\1\2\3\4')
        directory = "/misc/photos/#{dir}/"
        file_name = "#{format('%08d', directory_id)}#{extname}"
        upload_path = Rails.root.to_s
        upload_path += '/' unless upload_path.ends_with?('/')
        upload_path += "upload#{directory}#{file_name}"
        self.file_uri = %Q(/misc/attach_file/#{file_name})
        self.file_path = "/upload#{directory}#{file_name}"
        self.mkdir_for_file(upload_path)
        self.original_file_name = original_file_name
        mkdir_for_file(upload_path)
        File.delete(upload_path) if File.exist?(upload_path)
        File.open(upload_path, 'wb') { |f|
          f.write upload_file
        }
        if is_valid_imagefile
          reduce(upload_path,640,480)
        end
        self.save
        return true
      end
    end

    return false
  end

  def reduce(upload_path,width,height,options={})
    begin
      require 'RMagick'
      original = Magick::Image.read(upload_path).first
      resized = original.resize_to_fit(width,height)
      resized.write(upload_path)
      width = resized.columns
      height = resized.rows
      size = resized.filesize
      return [width, height,size]
    rescue
      return [0, 0,nil]
    end
  end

  def get_size(upload_file)
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


  def destroy_file
    begin
      return if self.file_path.blank?
      src = "#{Rails.root.to_s}#{self.file_path}"
      FileUtils.rm_rf(src)
      src_filename = src.gsub(/.*(\.\w{3}$)/iom, '\1')
      thumb_src = "#{src.gsub(/(\.\w{3}$)/,"")}_thumb#{src_filename}"
      FileUtils.rm_rf(thumb_src)
    rescue => e
      dump e
    end
  end

end
