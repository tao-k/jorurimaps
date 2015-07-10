# encoding: utf-8
class Gis::Map < ActiveRecord::Base
  include System::Model::Base
  include Gis::Model::Base::Config
  include System::Model::Search
  include System::Model::Operator
  include System::Model::SortNo
  include System::Model::FileUtil

  acts_as_paranoid
  belongs_to :admin_group, :class_name => "System::Group"
  belongs_to :admin_user, :class_name => "System::User"

  validates :code,              :presence => true
  validates :title,             :presence => true


  validates_uniqueness_of :code, :scope => [:deleted_at]

  has_many :maps_assortments, :foreign_key => :map_id,  :class_name => 'Gis::MapsAssortment', :order => 'sort_no', :dependent => :destroy
  has_many :assortments, :through => :maps_assortments, :order => 'gis_maps_assortments.sort_no'
  has_many :maps_relations, :foreign_key => :map_id,  :class_name => 'Gis::MapsRelation', :order => 'sort_no', :dependent => :destroy
  has_many :relations, :through => :maps_relations, :order => 'gis_maps_relations.sort_no'
  has_many :maps_layers, :foreign_key => :map_id,  :class_name => 'Gis::MapsLayer', :dependent => :destroy
  has_many :layers, :through => :maps_layers, :order => 'gis_maps_layers.sort_no'

  has_many :maps_stacks, :foreign_key => :map_id,  :class_name => 'Gis::MapsLayer', :dependent => :destroy
  has_many :stacks, :through => :maps_stacks, :order => 'gis_maps_layers.layer_order desc'

  has_many :portals_recognizers, :foreign_key => :portal_id,  :class_name => 'Gis::MapsRecognizer', :dependent => :destroy
  has_many :recognizers, :through => :portals_recognizers

  has_one :config, :foreign_key => :portal_id,  :class_name => 'Gis::MapConfig'

  def set_tmp_id
    return unless self.tmp_id.blank?
    self.tmp_id = Util::Sequencer.next_id(:tmp, :md5 => true)
  end

  def publishable
    return true if self.web_state != "public"
    return nil
  end

  def department
    return nil if admin_group.blank?
    root_group = System::Group.where(:level_no =>1).first
    if root_group
      ret = root_group.name
    else
      ret = ""
    end
    case admin_group.level_no
    when 2
      ret += admin_group.name
    when 3
      ret += admin_group.parent.name unless admin_group.parent.blank?
      ret += admin_group.name
    else
      return nil
    end
  end

  def state_select
    [["有効","enabled"],["無効","disabled"]]
  end

  def state_show
    select = state_select
    select.each{|a| return a[0] if a[1] == state}
    return nil
  end

  def parent_category_select(options={})
    if options[:include_blank]
      ret = [["なし",nil]]
    else
      ret = []
    end
    ret = ret.concat(Gis.yaml_to_array_for_select("gis_map_parent_category",:no_sort=>true))
    return ret
  end

  def parent_category_show
    select = parent_category_select
    categories = []
    select.each{|a|
       categories << a[0] if a[1] == parent_category_id
       categories << a[0] if a[1] == parent_category_id_1
       categories << a[0] if a[1] == parent_category_id_2
     }

    return nil if categories.blank?
    return categories.join(" , ")
  end

  def cache_clear_list
    parent_category_select.each do |category|
      Rails.cache.delete "portal_map_list_#{category[1]}"
    end
    Rails.cache.delete "portal_map_list"
  end

  def cache_clear
    parent_category_select.each do |category|
      Rails.cache.delete "portal_map_list_#{category[1]}"
    end
    Rails.cache.delete "portal_map_list"
    Rails.cache.delete "map_layer_list_#{self.id}_all"
    Rails.cache.delete "map_layer_list_#{self.id}_internal"
    Rails.cache.delete "map_layer_list_#{self.id}_all_normal"
    Rails.cache.delete "map_layer_list_#{self.id}_internal_normal"
    Rails.cache.delete "map_layer_list_#{self.id}_all_stack"
    Rails.cache.delete "map_layer_list_#{self.id}_internal_stack"
  end


  def is_portal
    return true if self.portal_kind == 1 || self.portal_kind == 2
    return false
  end


  def web_state_select
    if Core.user && Core.user.has_auth?(:manager)
      [["非公開","closed"],["内部公開","internal"],["全公開","public"]]
    else
      if self.web_state == "public"
        [["非公開","closed"],["内部公開","internal"],["全公開","public"]]
      else
        [["非公開","closed"],["内部公開","internal"]]
      end
    end
  end

  def web_state_all_select
    [["非公開","closed"],["内部公開","internal"],["外部公開","external"],["全公開","public"],["承認中","recognize"],["公開待ち","recognized"]]
  end

  def web_state_show
    select = web_state_all_select
    select.each{|a| return a[0] if a[1] == web_state }
    return nil
  end

  def portal_kind_select
    [["検索画面付きポータル",1], ["マップのみポータル",2], ["外部リンク",3],["添付ファイル", 4]]
  end

  def portal_kind_show
    select = portal_kind_select
    select.each{|a| return a[0] if a[1] == portal_kind }
    return nil
  end

  def user_kind_select
    [["個別ユーザ管理",1],["所属管理",2]]
  end

  def user_kind_show
    select = user_kind_select
    select.each{|a| return a[0] if a[1] == user_kind}
    return nil
  end

  def search(params)
    params.each do |n, v|
      next if v.to_s == ''
      case n
      when 's_keyword'
        search_keyword v,:title
      when 'p_group_id'
        unless v.to_i == 0
          condition = Condition.new()
          condition.and do |cond|
              cond.or :admin_group_id, '=', v
              cond.or :admin_user_id, '=', Site.user.id
            end
            self.and condition
        end
      end
    end if params.size != 0
    group_condition  = Condition.new()
    group_condition.or do |cond|
      cond.or "sql", "(user_kind = 2 and admin_group_id = #{Core.user_group.id})"
      cond.or "sql", "(user_kind = 1 and admin_user_id = #{Core.user.id})"
    end
    if (Core.user && Core.user.has_auth?(:manager)) || (Core.user && Core.user.has_auth?(:designer))
      #
    else
      web_state_cond = Condition.new()
      web_state_cond.and do |cond|
        cond.or :web_state ,"public"
        cond.or :web_state ,"internal"
        cond.or :web_state ,"recognize"
        cond.or :web_state ,"recognized"
        cond.or do |closed_web|
          closed_web.and group_condition
          closed_web.and :web_state, '=', "closed"
        end
      end

      self.and web_state_cond
    end

    return self
  end
  def get_maps_relations(params)
    if params[:relation]
      par_item = params[:relation]
      items = []
      par_item[:_relation_id].each_with_index{|p_item, n|
        i = p_item[0]
        items << Gis::MapsRelation.new({
                 :map_id => self.id,
                 :relation_id => par_item[:_relation_id]["#{i}"],
                 :sort_no => par_item[:_sort_no]["#{i}"]
               })
      }
      return items
    else
      return self.maps_relations
    end
  end


  def get_maps_assortments(params)
    if params[:assortment]
      par_item = params[:assortment]
      items = []
      par_item[:_assortment_id].each_with_index{|p_item, n|
        i = p_item[0]
        items << Gis::MapsAssortment.new({
                 :map_id => self.id,
                 :assortment_id => par_item[:_assortment_id]["#{i}"],
                 :sort_no => par_item[:_sort_no]["#{i}"]
               })
      }
      return items
    else
      return self.maps_assortments
    end
  end

  def get_maps_layers(params)
    if params[:layer]
      par_item = params[:layer]
      items = []
      par_item[:_layer_id].each_with_index{|p_item, n|
        i = p_item[0]
        items << Gis::MapsLayer.new({
                 :map_id => self.id,
                 :layer_id => par_item[:_layer_id]["#{i}"],
                 :sort_no => par_item[:_sort_no]["#{i}"],
                 :layer_order => par_item[:_layer_order]["#{i}"],
               })
      }
      return items
    else
      return self.maps_layers
    end
  end

  def save_relations(par_item)
    ma = []
    no_del = []
    maps_relations.each do |maps_relation|
      ma << maps_relation
    end unless maps_relations.blank?
    if ma.blank? || par_item[:_rid].blank?
      par_item[:_relation_id].each_with_index{|p_item, n|
         i = p_item[0]
        next if par_item[:_relation_id]["#{i}"].blank?
        dup_item = Gis::MapsRelation.find(:first, :conditions=>["map_id = ? AND relation_id = ?", self.id, par_item[:_relation_id]["#{i}"]])
        if dup_item.blank?
          new_item = Gis::MapsRelation.create({
               :map_id => self.id,
               :relation_id => par_item[:_relation_id]["#{i}"],
               :sort_no => par_item[:_sort_no]["#{i}"]
             })
        end
      }
    else
      par_item[:_relation_id].each_with_index{|p_item, n|
      i = p_item[0]
      if par_item[:_rid]["#{i}"].blank?
        create_ok = false
        create_ok = true if par_item[:_destroy].blank?
        create_ok = true if par_item[:_destroy] && par_item[:_destroy]["#{i}"].blank?
        create_ok = false if par_item[:_relation_id]["#{i}"].blank?
        if create_ok
          new_item = Gis::MapsRelation.create({
             :map_id => self.id,
             :relation_id => par_item[:_relation_id]["#{i}"],
             :sort_no => par_item[:_sort_no]["#{i}"]
           })
        end
      else
        ma_item = nil
        ma.each{|x|
           ma_item = x if x.rid == par_item[:_rid]["#{i}"].to_i
        }
         if ma_item
           if par_item[:_destroy] && par_item[:_destroy]["#{i}"]
             #
           elsif par_item[:_relation_id]["#{i}"].blank?
             #
           else
             ma_item.sort_no = par_item[:_sort_no]["#{i}"]
             ma_item.save
             no_del << par_item[:_rid]["#{i}"].to_i
           end
         else
           if par_item[:_destroy] && par_item[:_destroy]["#{i}"].blank?  && !par_item[:_relation_id]["#{i}"].blank?
             new_item = Gis::MapsRelation.create({
               :map_id => self.id,
               :relation_id => par_item[:_relation_id]["#{i}"],
               :sort_no => par_item[:_sort_no]["#{i}"]
             })
           end
         end
      end
      }
      ma.each{|a| a.destroy if no_del.index(a.rid).blank?}
    end
  end



  def save_assortments(par_item)
    ma = []
    no_del = []
    maps_assortments.each do |maps_assortment|
      ma << maps_assortment
    end unless maps_assortments.blank?
    if ma.blank? || par_item[:_rid].blank?

      par_item[:_assortment_id].each_with_index{|p_item, n|
        i = p_item[0]
        next if par_item[:_assortment_id]["#{i}"].blank?
        dup_item = Gis::MapsAssortment.find(:first, :conditions=>["map_id = ? AND assortment_id = ?", self.id, par_item[:_assortment_id]["#{i}"]])
        if dup_item.blank?
          new_item = Gis::MapsAssortment.create({
               :map_id => self.id,
               :assortment_id => par_item[:_assortment_id]["#{i}"],
               :sort_no => par_item[:_sort_no]["#{i}"]
             })
        end
      }
    else
      par_item[:_assortment_id].each_with_index{|p_item, n|
      i = p_item[0]
      if par_item[:_rid]["#{i}"].blank?
        create_ok = false
        create_ok = true if par_item[:_destroy].blank?
        create_ok = true if par_item[:_destroy] && par_item[:_destroy]["#{i}"].blank?
        create_ok = false if par_item[:_assortment_id]["#{i}"].blank?
        if create_ok
          new_item = Gis::MapsAssortment.create({
             :map_id => self.id,
             :assortment_id => par_item[:_assortment_id]["#{i}"],
             :sort_no => par_item[:_sort_no]["#{i}"]
           })
        end
      else
        ma_item = nil
        ma.each{|x|
           ma_item = x if x.rid == par_item[:_rid]["#{i}"].to_i
        }
         if ma_item
           if par_item[:_destroy] && par_item[:_destroy]["#{i}"]
             #
           elsif par_item[:_assortment_id]["#{i}"].blank?
             #
           else
             ma_item.sort_no = par_item[:_sort_no]["#{i}"]
             ma_item.save
             no_del << par_item[:_rid]["#{i}"].to_i
           end
         else
           if par_item[:_destroy] && par_item[:_destroy]["#{i}"].blank?  && !par_item[:_assortment_id]["#{i}"].blank?
             new_item = Gis::MapsAssortment.create({
               :map_id => self.id,
               :assortment_id => par_item[:_assortment_id]["#{i}"],
               :sort_no => par_item[:_sort_no]["#{i}"]
             })
           end
         end
      end
      }
      ma.each{|a| a.destroy if no_del.index(a.rid).blank?}
    end
  end

  def save_layers(par_item)
    ml = []
    no_del = []
    maps_layers.each do |maps_layer|
      ml << maps_layer
    end unless maps_layers.blank?
    if ml.blank? || par_item[:_rid].blank?

      par_item[:_layer_id].each_with_index{|p_item, n|
        i = p_item[0]
        next if par_item[:_layer_id]["#{i}"].blank?
        dup_item = Gis::MapsLayer.find(:first, :conditions=>["map_id = ? AND layer_id = ?", self.id, par_item[:_layer_id]["#{i}"]])
        if dup_item.blank?
          new_item = Gis::MapsLayer.create({
               :map_id => self.id,
               :layer_id => par_item[:_layer_id]["#{i}"],
               :sort_no => par_item[:_sort_no]["#{i}"],
               :layer_order => par_item[:_layer_order]["#{i}"]
             })
        end
      }
    else
      par_item[:_layer_id].each_with_index{|p_item, n|
      i = p_item[0]
      if par_item[:_rid]["#{i}"].blank?
        create_ok = false
        create_ok = true if par_item[:_destroy].blank?
        create_ok = true if par_item[:_destroy] && par_item[:_destroy]["#{i}"].blank?
        create_ok = false if par_item[:_layer_id]["#{i}"].blank?
        if create_ok
          new_item = Gis::MapsLayer.create({
             :map_id => self.id,
             :layer_id => par_item[:_layer_id]["#{i}"],
             :sort_no => par_item[:_sort_no]["#{i}"],
             :layer_order => par_item[:_layer_order]["#{i}"]
           })
        end
      else
        ml_item = nil
        ml.each{|x|
           ml_item = x if x.rid == par_item[:_rid]["#{i}"].to_i
        }
         if ml_item
           if par_item[:_destroy] && par_item[:_destroy]["#{i}"]
             #
           elsif par_item[:_layer_id]["#{i}"].blank?
             #
           else
             ml_item.sort_no = par_item[:_sort_no]["#{i}"]
             ml_item.layer_order = par_item[:_layer_order]["#{i}"]
             ml_item.save
             no_del << par_item[:_rid]["#{i}"].to_i
           end
         else
           if par_item[:_destroy] && par_item[:_destroy]["#{i}"].blank?  && !par_item[:_layer_id]["#{i}"].blank?
             new_item = Gis::MapsLayer.create({
               :map_id => self.id,
               :layer_id => par_item[:_layer_id]["#{i}"],
               :sort_no => par_item[:_sort_no]["#{i}"],
               :layer_order => par_item[:_layer_order]["#{i}"]
             })
           end
         end
      end
      }
      ml.each{|a| a.destroy if no_del.index(a.rid).blank?}
    end
  end

  def save_files
    return if self.tmp_id.blank?
    Gis::MapLegendFile.update_all("map_id = #{self.id}", "tmp_id = '#{self.tmp_id}'")
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

  def save_thumb(upload_item, is_delete)
    if is_delete
      self.thumb_uri = nil
      self.thumb_path = nil
      self.save
    else
      return if upload_item.blank?
      file = upload_item
      return if file.blank?
      upload_file = file.read
      original_file_name = file.original_filename # ファイル名
      extname = File.extname(original_file_name) # 拡張子を抽出
      extname_judges = [".jpeg", ".jpg", ".png", ".gif"]
      is_valid_imagefile = true
      is_valid_imagefile = false if extname_judges.index(extname.downcase).blank? # downcase：小文字に揃える、index：配列を検索
      if is_valid_imagefile
        upload_photo_size = get_size(upload_file)
        tmp_id = self.id.to_s
        dir = tmp_id.gsub(/(.*)(..)(..)(..)$/, '\1/\2/\3/\4/\1\2\3\4')
        directory = "/gis/portal/thumb/#{dir}/"
        file_name = "#{format('%08d', self.id.to_s)}#{extname}"
        upload_path = Rails.root.to_s
        upload_path += '/' unless upload_path.ends_with?('/')
        upload_path += "public#{directory}#{file_name}"
        self.thumb_uri = %Q(#{directory}#{file_name})
        self.thumb_path = "/public#{directory}#{file_name}"
        self.mkdir_for_file(upload_path)
        mkdir_for_file(upload_path)
        File.delete(upload_path) if File.exist?(upload_path)
        File.open(upload_path, 'wb') { |f|
          f.write upload_file
        }
        reduce(upload_path, 136, 90)
        self.save
      else
        return
      end
    end
  end

  def save_icon(upload_item, is_delete)
    if is_delete
      self.icon_uri = nil
      self.icon_path = nil
      self.save
    else
      return if upload_item.blank?
      file = upload_item
      return if file.blank?
      upload_file = file.read
      original_file_name = file.original_filename # ファイル名
      extname = File.extname(original_file_name) # 拡張子を抽出
      extname_judges = [".jpeg", ".jpg", ".png", ".gif"]
      is_valid_imagefile = true
      is_valid_imagefile = false if extname_judges.index(extname.downcase).blank? # downcase：小文字に揃える、index：配列を検索
      if is_valid_imagefile
        upload_photo_size = get_size(upload_file)
        tmp_id = self.id.to_s
        dir = tmp_id.gsub(/(.*)(..)(..)(..)$/, '\1/\2/\3/\4/\1\2\3\4')
        directory = "/gis/portal/icon/#{dir}/"
        file_name = "#{format('%08d', self.id.to_s)}#{extname}"
        upload_path = Rails.root.to_s
        upload_path += '/' unless upload_path.ends_with?('/')
        upload_path += "public#{directory}#{file_name}"
        self.icon_uri = %Q(#{directory}#{file_name})
        self.icon_path = "/public#{directory}#{file_name}"
        self.mkdir_for_file(upload_path)
        mkdir_for_file(upload_path)
        File.delete(upload_path) if File.exist?(upload_path)
        File.open(upload_path, 'wb') { |f|
          f.write upload_file
        }
        reduce(upload_path, 48, 48)
        self.save
      else
        return
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

  def save_with_rels(assort_item, layer_item, upload_item,icon_deltete,thumb_upload_file, thumb_delete,relation_items, mode = :create)
    if self.valid?
      self.sort_no = get_max_sort_no if self.sort_no.blank?
      self.save
      self.save_assortments(assort_item)
      self.save_layers(layer_item)
      self.save_relations(relation_items)
      self.save_files
      self.save_icon(upload_item,icon_deltete)
      self.save_thumb(thumb_upload_file, thumb_delete)
      return true
    else
      return false
    end
  end


end
