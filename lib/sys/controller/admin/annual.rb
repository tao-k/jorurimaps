# coding: utf-8
require 'csv'
module Sys::Controller::Admin::Annual

  def import_csv_data(params, start_at)
    column = nil
    data = nil
    count = 0
    csv = NKF.nkf('-w', params[:item][:file].read)
    CSV.parse(csv) do |row|
      if column.blank?
        column = row
        next
      else
        data = {}
        row.each_with_index{|row_item, i|
          next if row_item.blank?
          next if column[i].blank?
          data[column[i].to_sym] = row_item
        }
      end
      item = System::GroupChange.new
      item.start_date = start_at
      old_group = System::Group.find(:first, :conditions=>["state = ? and deleted_at IS NULL and code = ?", "enabled",data[:old_code]])
      next if old_group.blank?
      data[:old_id] = old_group.id
      item.attributes = data
      item.save
      count += 1
    end
    return {:result => true, :count => count}
  end

  def do_annual_change(start_at)
    return if start_at.blank?
    @start_at = start_at
    @target_models = []
    dump "Gis::Script::Annual.do_annual_change 組織変更にともなうid振り替え処理、#{Time.now.strftime("%Y-%m-%d %H:%M:%S")}に作業開始"
    items = System::GroupChange.find(:all, :conditions=>["start_date = ?",@start_at])
    if items.blank?
      dump "Gis::Script::Annual.do_annual_change 組織変更にともなうid振り替え処理、振り替え設定がないため終了#{Time.now.strftime("%Y-%m-%d %H:%M:%S")}"
    else
      #disable_project
      items.each do |item|
        new_group = System::Group.find(:first, :conditions=>["code = ? and state = ?", item.code, "enabled"])
        if new_group.blank?
          if item.change_division.to_i != 5
            dump "Gis::Script::Annual.do_annual_change #{item.old_code}#{item.old_name}　#{item.code}#{item.name}新引継ぎ先所属が存在しないため中断#{Time.now.strftime("%Y-%m-%d %H:%M:%S")}"
            next
          end
        else
          #item.group_id = new_group.id
          #item.save(:validate=>false)
          @new_group_id = new_group.id
        end
        case item.change_division.to_i
        when 1
          dump "Gis::Script::Annual.do_annual_change #{item.old_code}#{item.old_name}　#{item.code}#{item.name}　新規所属はスキップ#{Time.now.strftime("%Y-%m-%d %H:%M:%S")}"
          next
        when 2
          #change_group_name(item)
          dump "Gis::Script::Annual.do_annual_change #{item.old_code}#{item.old_name}　#{item.code}#{item.name}　名称変更はスキップ#{Time.now.strftime("%Y-%m-%d %H:%M:%S")}"
          next
        when 3
          move_to_new_group(item,new_group)
        when 4
        #  transfer_group_name(item)
          dump "Gis::Script::Annual.do_annual_change #{item.old_code}#{item.old_name}　#{item.code}#{item.name}　所属移動はスキップ#{Time.now.strftime("%Y-%m-%d %H:%M:%S")}"
          next
        when 5
          close_group_name(item)
          #dump "Gis::Script::Annual.do_annual_change #{item.old_code}#{item.old_name}　#{item.code}#{item.name}　所属非公開はスキップ#{Time.now.strftime("%Y-%m-%d %H:%M:%S")}"
          next
        else
          dump "Gis::Script::Annual.do_annual_change #{item.old_code}#{item.old_name}　#{item.old_code}#{item.old_name}種別が正しくないためスキップ#{Time.now.strftime("%Y-%m-%d %H:%M:%S")}"
        end
      end
    end
  end





  def change_group_name(item)
    dump "Gis::Script::Annual.do_annual_change #{item.old_code}#{item.old_name}　#{item.old_code}#{item.old_name}所属名変更#{Time.now.strftime("%Y-%m-%d %H:%M:%S")}"
    #
  end

  def move_to_new_group(item,new_group)
    dump "Gis::Script::Annual.do_annual_change #{item.old_code}#{item.old_name}　#{item.old_code}#{item.old_name}所属idを新しいものに振り替え#{Time.now.strftime("%Y-%m-%d %H:%M:%S")}"
    Gis::Assortment.update_all("admin_group_id = #{new_group.id}","admin_group_id = #{item.old_id}")
    Gis::Layer.update_all("admin_group_id = #{new_group.id}","admin_group_id = #{item.old_id}")
    Gis::Map.update_all("admin_group_id = #{new_group.id}","admin_group_id = #{item.old_id}")
    Gis::Mapfile.update_all("admin_group_id = #{new_group.id}","admin_group_id = #{item.old_id}")
    Gis::LayersManager.update_all("group_id = #{new_group.id}","group_id = #{item.old_id}")
  end

  def transfer_group_name(item)
    dump "Gis::Script::Annual.do_annual_change #{item.old_code}#{item.old_name}　所属名称を新所属に振り替え#{Time.now.strftime("%Y-%m-%d %H:%M:%S")}"
    Gis::Assortment.update_all("admin_group_id = #{new_group.id}","admin_group_id = #{item.old_id}")
    Gis::Layer.update_all("admin_group_id = #{new_group.id}","admin_group_id = #{item.old_id}")
    Gis::Map.update_all("admin_group_id = #{new_group.id}","admin_group_id = #{item.old_id}")
    Gis::Mapfile.update_all("admin_group_id = #{new_group.id}","admin_group_id = #{item.old_id}")
  end

  def close_group_name(item)
    dump "Gis::Script::Annual.do_annual_change #{item.old_code}#{item.old_name}　抹消される所属管理IDを削除#{Time.now.strftime("%Y-%m-%d %H:%M:%S")}"
    #if item.old_id.blank?
    #  dump "Gis::Script::Annual.do_annual_change #{item.old_code}#{item.old_name}　所属ID不明#{Time.now.strftime("%Y-%m-%d %H:%M:%S")}"
    #  return
    #end
    #@target_models.each do |target|
    #  target.update_all("state = 'closed'","admin_group_id = #{item.old_id}")
    #end
    Gis::LayersManager.destroy_all("group_id = #{item.old_id}")
  end

end
