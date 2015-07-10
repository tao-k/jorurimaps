# encoding: utf-8
class Gis::Mapfile < ActiveRecord::Base
  include System::Model::Base
  include Gis::Model::Base::Config
  include System::Model::Search
  include System::Model::Operator
  include System::Model::FileUtil

  acts_as_paranoid

  has_many :histories, :class_name=>"Gis::MapfileHistory", :foreign_key => "mapfile_id", :dependent => :destroy
  belongs_to :admin_group, :class_name => "System::Group"
  belongs_to :admin_user, :class_name => "System::User"

  validates :title,            :presence => true
  validate  :file_name,        :presence => true
  validates :body,             :presence => true

  validates_uniqueness_of :file_name, :scope => [:deleted_at]

  before_save :set_column
  after_save :send_mapfile
  after_destroy :destroy_file

  def state_select
    [["有効","enabled"],["無効","disabled"]]
  end

  def state_show
    select = state_select
    select.each{|a| return a[0] if a[1] == state}
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

  def set_column
    if self.file_directory.blank?
      upload_directory = Application.config(:mapfile_directory, "/var/share/gis_mapfiles")
    else
      upload_directory = self.file_directory
    end

    upload_path = "#{upload_directory}/#{file_name}"
    self.file_path = upload_path
    self.file_directory = upload_directory
  end

  def send_mapfile
    mkdir_for_file(file_path)
    begin
      File.delete(file_path) if File.exist?(file_path)
      File.open(file_path, 'wb') { |f| f.write(body) }
    rescue => e
      dump e
    end
  end

  def save_history
    item = Gis::MapfileHistory.new
    Gis::Mapfile.column_names.each do |column_name|
      next if column_name == "id"
      next if column_name == "updated_at"
      next if column_name == "created_at"
      eval("item.#{column_name} = self.#{column_name}")
    end
    item.mapfile_id = self.id
    item.save(:validate => false)
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

    return self
  end



  def destroy_file
    begin
      src = "#{self.file_directory}/#{self.file_name}"
      FileUtils.rm_rf(src)
    rescue => e
      dump e
    end
  end


end
