# encoding: utf-8
class Gis::LayerDataPhoto < ActiveRecord::Base
  include System::Model::Base
  include System::Model::Base::Config
  include System::Model::Search
  include System::Model::Operator
  include System::Model::FileUtil
  include Gis::Model::Geometry

  acts_as_paranoid
  set_rgeo_factory_for_column(:g, RGeo::Geographic.spherical_factory(:srid => 4326))

  belongs_to :parent, :class_name => "Gis::LayerDatum", :foreign_key => :layer_data_id


  before_save :save_geometry

  def save_geometry
    self.g = wgs84_factory.point(self.parent.lng, self.parent.lat) if self.parent
  end


  def state_select
    [["公開","public"],["非公開","closed"]]
  end

  def state_show
    select = state_select
    select.each{|a| return a[0] if a[1] == web_state}
    return nil
  end

  def upload_directory_setting
    "upload/gis/facility/#{self.parent.rid}/#{format('%08d', self.rid)}/" #UDはuploadなし
  end

  def show_width(tumnb=true)
    if tumnb
      return 200 if width > 200
      return width
    else
      return witdh
    end
  end

  def directory_prefix
    ""  #UDはpublic
  end

  def public_caption(default_str=nil)
    return self.caption unless self.caption.blank?
    return default_str unless default_str.blank?
    return self.parent.name if self.parent
    return nil
  end

  def public_original_photo_path
    "/gis/layers/#{self.rid}/original"
  end

  def public_photo_path
    "/gis/layers/#{self.rid}/photo"
  end

  def thumbnail_public_photo_path
    "/gis/layers/#{self.rid}/thumbnail"
  end


  def manage_photos(parent, par_item,mode=:create)
    save_with_file(parent, par_item[:photo])
    return true
  end

  def save_with_file(parent, par_item)
    return false if par_item.blank?
    par_item[:_caption].each_with_index do |p_item, n|
      i = p_item[0]
      if par_item[:_rid] && par_item[:_rid]["#{i}"]
        item = Gis::LayerDataPhoto.where(:rid => par_item[:_rid]["#{i}"]).first || nil
        next if item.blank?
        if par_item[:_destroy] && par_item[:_destroy]["#{i}"] && par_item[:_destroy]["#{i}"].to_i == 1
          item.destroy
          next
        else
          item.caption = par_item[:_caption]["#{i}"] unless par_item[:_caption].blank?
          item.sort_no = par_item[:_sort_no]["#{i}"] unless par_item[:_sort_no].blank?

          if par_item[:_state].blank?
            item.web_state = "closed"
          else
            if par_item[:_state]["#{i}"]
              item.web_state = "public"
            else
              item.web_state = "closed"
            end
          end
          item.save
          next
        end
      end
    end
    return if par_item[:upload].blank?
    par_item[:upload].each_with_index do |p_item, n|
      i = p_item[0]
      file = p_item[1]
      upload_file = file.read
      original_file_name = file.original_filename # ファイル名
      extname = File.extname(original_file_name) # 拡張子を抽出
      extname_judges = [".jpeg", ".jpg", ".png", ".gif"]
      is_valid_imagefile = true
      is_valid_imagefile = false if extname_judges.index(extname.downcase).blank? # downcase：小文字に揃える、index：配列を検索
      if is_valid_imagefile
        if par_item[:_rid] && par_item[:_rid]["#{i}"]
          item = Gis::LayerDataPhoto.where(:rid => par_item[:_rid]["#{i}"]).first || Gis::LayerDataPhoto.new
          next if par_item[:_destroy] && par_item[:_destroy]["#{i}"]
        else
          item = Gis::LayerDataPhoto.new
        end
        item.layer_data_id = parent.rid
        item.layer_id      = parent.layer.id if parent.layer
        item.original_file_name = original_file_name
        if par_item[:_state].blank?
          item.web_state = "closed"
        else
          if par_item[:_state]["#{i}"]
            item.web_state = "public"
          else
            item.web_state = "closed"
          end
        end
        item.caption = par_item[:_caption]["#{i}"] unless par_item[:_caption].blank?
        item.sort_no = par_item[:_sort_no]["#{i}"] unless par_item[:_sort_no].blank?
        upload_photo_size = get_size(upload_file)
        item.width = upload_photo_size[0]
        item.height = upload_photo_size[1]
        item.size = upload_file.size.to_i
        next if upload_file.size.to_i > 1024 * 1024 * 5
        if item.save
          next if par_item[:_rid] && par_item[:_rid]["#{i}"]
          directory = item.upload_directory_setting
          file_name = "#{format('%08d', item.rid)}#{extname}"
          upload_path = Rails.root.to_s
          upload_path += '/' unless upload_path.ends_with?('/')
          upload_path += "#{directory_prefix}#{directory}#{file_name}"
          item.original_file_uri = %Q(#{directory}#{file_name})
          item.original_file_path = "/#{directory_prefix}#{directory}#{file_name}"
          item.mkdir_for_file(upload_path)

          begin
            File.delete(upload_path) if File.exist?(upload_path)
            File.open(upload_path, 'wb') { |f|
              f.write upload_file
            }
          rescue => e
            dump e
          end
          if item.width > 1600 || item.height > 1200
            resized_size = reduce(upload_path,1600,1200)
            item.width = resized_size[0]
            item.height = resized_size[1]
            item.size = resized_size[2]
          end


          reduce_path = resize(upload_path,item.original_file_path,640,480,"reduce")
          if reduce_path
            item.file_path = reduce_path
            item.file_uri= %Q(#{directory}#{file_name})
          end
          thumb_path = resize(upload_path,item.original_file_path,240,180,"thumb")
          if thumb_path
            item.thumb_file_path = thumb_path
            item.thumb_file_uri= %Q(#{directory}#{file_name})
          end
          item.save
        end
      end
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
  def resize(upload_path,file_path, width,height,path_prefix = "thumb")
    original_path = upload_path
    thumb_file_name = original_path.gsub(/.*(\.\w{3}$)/iom, '\1')
    thumb_path      = %Q(#{original_path.gsub(/(\.\w{3}$)/,"")}_#{path_prefix}#{thumb_file_name})
    begin
      require 'RMagick'
      original = Magick::Image.read(original_path).first
      FileUtils::cp(original_path,thumb_path)
      resized = original.resize_to_fit(width,height)
      resized.write(thumb_path)
      ret = %Q(#{file_path.gsub(/(\.\w{3}$)/,"")}_#{path_prefix}#{thumb_file_name})
      return ret
    rescue => e
      dump e
      return nil
    end
  end



  def update_photo_information(parent, par_item)
    is_imagefile_update = false
    unless par_item[:upload].blank?
      is_imagefile_update = true
      file = par_item[:upload]
      upload_file = file.read
      original_file_name = file.original_filename # ファイル名
      extname = File.extname(original_file_name) # 拡張子を抽出
      extname_judges = [".jpeg", ".jpg", ".png", ".gif"]
      is_valid_imagefile = true
      is_valid_imagefile = false if extname_judges.index(extname.downcase).blank? # downcase：小文字に揃える、index：配列を検索
      if is_valid_imagefile
        self.original_file_name = original_file_name
        is_imagefile_update = true
      else
        return false
      end
    end
    self.web_state = par_item[:state]
    self.caption = par_item[:caption]
    self.sort_no = par_item[:sort_no]
    if self.save
      if is_imagefile_update
        directory = upload_directory_setting
        file_name = "#{format('%08d', self.id)}#{extname}"
        upload_path = Rails.root.to_s
        upload_path += '/' unless upload_path.ends_with?('/')
        upload_path += "#{directory}#{file_name}"
        self.file_uri = %Q(#{directory}#{file_name})
        self.file_path = "#{directory}#{file_name}"
        self.mkdir_for_file(upload_path)
        mkdir_for_file(upload_path)
        File.delete(upload_path) if File.exist?(upload_path)
        File.open(upload_path, 'wb') { |f|
          f.write upload_file
        }
        self.save
      end
    end
    return true
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
