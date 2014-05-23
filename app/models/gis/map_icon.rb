# encoding: utf-8
class Gis::MapIcon < ActiveRecord::Base
  include System::Model::Base
  include System::Model::Base::Config
  include System::Model::Operator
  include System::Model::FileUtil
  include System::Model::SortNo


  validates :state,              :presence => true
  validates :title,              :presence => true

  validates :sort_no,            :presence => true, :numericality => {:allow_blank => true}

  after_destroy :destroy_file
  def offset_x
    return width.to_f / 2
  end

  def offset_y
    case position_offset
    when 1
      height
    else
      height.to_f / 2
    end
  end



  def status_select
    [["公開","public"], ["非公開","closed"]]
  end

  def status_show
    status_select.each{|a| return a[0] if a[1] == state}
  end


  def offset_select
    [["ピン表示",1], ["中央表示",0]]
  end

  def offset_show
    offset_select.each{|a| return a[0] if a[1] == position_offset}
  end



  def save_with_file(par_item, mode=:create)
    return false if par_item.blank?

    self.title = par_item[:title]
    self.state = par_item[:state]
    self.caption = par_item[:caption]
    self.sort_no = par_item[:sort_no]
    self.position_offset  = par_item[:position_offset]

    self.errors.add(:title, "を入力してください。")   if self.title.blank?
    self.errors.add(:state, "を選択してください。")   if self.state.blank?
    self.sort_no = get_max_sort_no if self.sort_no.blank?
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
      original_file_name = file.original_filename # ファイル名
      extname = File.extname(original_file_name) # 拡張子を抽出
      extname_judges = [".jpeg", ".jpg", ".png", ".gif"]
      is_valid_imagefile = true
      is_valid_imagefile = false if extname_judges.index(extname.downcase).blank? # downcase：小文字に揃える、index：配列を検索
      self.errors.add(:upload, "はjpeg, jpg, png, gifの拡張子以外の画像をアップロードできません。") unless is_valid_imagefile
      if is_valid_imagefile
        upload_photo_size = get_size(upload_file)
        #970px × 238px
        self.errors.add(:upload, "の横サイズは300px以内としてください。") if upload_photo_size[0] > 300 if upload_photo_size[0] != 0 && upload_photo_size[1] != 0
        self.errors.add(:upload, "として1MB以上のファイルサイズの画像はアップロードできません。") if upload_photo_size[2] > 1024 * 1024 * 1 if upload_photo_size[2] != 0
        self.width = upload_photo_size[0]
        self.height = upload_photo_size[1]
      end
      return false if self.errors.size > 0
      if self.save
        tmp_id = self.id.to_s
        dir = tmp_id.gsub(/(.*)(..)(..)(..)$/, '\1/\2/\3/\4/\1\2\3\4')
        directory = "/gis/map/icon/#{dir}/"
        file_name = "#{format('%08d', self.id.to_s)}#{extname}"
        upload_path = Rails.root.to_s
        upload_path += '/' unless upload_path.ends_with?('/')
        upload_path += "public#{directory}#{file_name}"
        self.file_uri = %Q(#{directory}#{file_name})
        self.file_path = "/public#{directory}#{file_name}"
        self.mkdir_for_file(upload_path)
        self.original_file_name = original_file_name
        mkdir_for_file(upload_path)
        File.delete(upload_path) if File.exist?(upload_path)
        File.open(upload_path, 'wb') { |f|
          f.write upload_file
        }
        self.save
        return true
      end
    end

    return false
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


  def resize(upload_path)
    original_path = "#{Rails.root.to_s}/public#{upload_path}"
    thumb_file_name = original_path.gsub(/.*(\.\w{3}$)/iom, '\1')
    thumb_path      = %Q(#{original_path.gsub(/(\.\w{3}$)/,"")}_thumb#{thumb_file_name})
    begin
      require 'RMagick'
      original = Magick::Image.read(original_path).first
      FileUtils::cp(original_path,thumb_path)
      resized = original.resize_to_fit(240,180)
      resized.write(thumb_path)
      ret = %Q(#{upload_path.gsub(/(\.\w{3}$)/,"")}_thumb#{thumb_file_name})
      return ret
    rescue => e
      dump e
      return nil
    end
  end


  def destroy_file
    begin
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
