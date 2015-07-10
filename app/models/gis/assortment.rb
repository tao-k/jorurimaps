# encoding: utf-8
class Gis::Assortment < ActiveRecord::Base
  include System::Model::Base
  include Gis::Model::Base::Config
  include System::Model::Search
  include System::Model::Operator


  acts_as_paranoid
  belongs_to :admin_group, :class_name => "System::Group"
  belongs_to :admin_user, :class_name => "System::User"

  has_many :assortments_layers, :foreign_key => :assortment_id,  :class_name => 'Gis::AssortmentsLayer', :order => 'sort_no', :dependent => :destroy
  has_many :layers, :through => :assortments_layers, :order => 'gis_assortments_layers.sort_no'

  has_many :assortments_stacks, :foreign_key => :assortment_id,  :class_name => 'Gis::AssortmentsLayer', :order => 'sort_no', :dependent => :destroy
  has_many :stacks, :through => :assortments_stacks, :order => 'gis_assortments_layers.layer_order desc'

  has_many :maps_assortments, :foreign_key => :assortment_id,  :class_name => 'Gis::MapsAssortment', :dependent => :destroy
  has_many :maps, :through => :maps_assortments,:source => :map, :order => 'gis_maps_assortments.sort_no'

  validates :title,              :presence => true


  def set_tmp_id
    if tmp_id.blank?
      tmp_seq = Util::Sequencer.next_id('folders_file', :md5 => true)
      self.tmp_id = tmp_seq.to_s
    end
  end


  def user_kind_select
    [["個別ユーザ管理",1],["所属管理",2]]
  end


  def web_state_select
    [["非公開","closed"],["内部公開","internal"],["全公開","all"]]
  end

  def web_state_show
    web_state_select.each{|a| return a[0] if a[1] == web_state}
    return nil
  end

  def admin_group_name
    return "" if admin_group.blank?
    return admin_group.name
  end

  def cache_clear
    Rails.cache.delete "folder_layer_list_#{self.id}_all"
    Rails.cache.delete "folder_layer_list_#{self.id}_internal"
    Rails.cache.delete "folder_layer_list_#{self.id}_all_normal"
    Rails.cache.delete "folder_layer_list_#{self.id}_internal_normal"
    Rails.cache.delete "folder_layer_list_#{self.id}_all_stack"
    Rails.cache.delete "folder_layer_list_#{self.id}_internal_stack"
    #assorment_maps = self.maps
    #assorment_maps.each do |a_map|
    #  a_map.cache_clear
    #end
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

    return self
  end

  def get_assortments_layers(params)
    if params[:layer]
      par_item = params[:layer]
      items = []
      par_item[:_layer_id].each_with_index{|p_item, i|
        items << Gis::AssortmentsLayer.new({
                 :assortment_id => self.id,
                 :layer_id => par_item[:_layer_id]["#{i}"],
                 :sort_no => par_item[:_sort_no]["#{i}"],
                 :layer_order => par_item[:_layer_order]["#{i}"]
               })
      }
      return items
    else
      return self.assortments_layers
    end
  end

  def save_with_rels(par_item, mode = :create)
    if self.valid?
      self.save
      al = []
      no_del = []
      assortments_layers.each do |assort_layer|
        al << assort_layer
      end unless assortments_layers.blank?
      if al.blank? || par_item[:_rid].blank?
        par_item[:_layer_id].each_with_index{|p_item, n|
          i = p_item[0]
          next if par_item[:_layer_id]["#{i}"].blank?
          dup_item = Gis::AssortmentsLayer.find(:first, :conditions=>["assortment_id = ? AND layer_id = ?", self.id, par_item[:_layer_id]["#{i}"]])
          if dup_item.blank?
            new_item = Gis::AssortmentsLayer.create({
                 :assortment_id => self.id,
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
              new_item = Gis::AssortmentsLayer.create({
                 :assortment_id => self.id,
                 :layer_id => par_item[:_layer_id]["#{i}"],
                 :sort_no => par_item[:_sort_no]["#{i}"],
                 :layer_order => par_item[:_layer_order]["#{i}"]
               })
            end
          else
            al_item = nil
            al.each{|x|
               al_item = x if x.rid == par_item[:_rid]["#{i}"].to_i
            }
             if al_item
               if par_item[:_destroy] && par_item[:_destroy]["#{i}"]
                 #
               elsif par_item[:_layer_id]["#{i}"].blank?
                 #
               else
                 al_item.sort_no = par_item[:_sort_no]["#{i}"]
                 al_item.layer_order = par_item[:_layer_order]["#{i}"]
                 al_item.save
                 no_del << par_item[:_rid]["#{i}"].to_i
               end
             else
               if par_item[:_destroy] && par_item[:_destroy]["#{i}"].blank?  && !par_item[:_layer_id]["#{i}"].blank?
                 new_item = Gis::AssortmentsLayer.create({
                   :assortment_id => self.id,
                   :layer_id => par_item[:_layer_id]["#{i}"],
                   :sort_no => par_item[:_sort_no]["#{i}"],
                 :layer_order => par_item[:_layer_order]["#{i}"]
                 })
               end
             end
          end
          }
          al.each{|a| a.destroy if no_del.index(a.rid).blank?}
        end
      return true
    else
      return false
    end
  end

end
