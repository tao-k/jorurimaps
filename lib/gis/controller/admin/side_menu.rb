# encoding: utf-8
module Gis::Controller::Admin::SideMenu

  def side_menu
    item = @model.new#.readable
    item.search params
    item.order params[:sort], :updated_at
    @items = item.find(:all)
    @count_hash = {}
    @items.each do |x|
      admin_group = x.admin_group
      if admin_group
        if @count_hash[admin_group.id].blank?
          @count_hash[admin_group.id] = {:count =>1 , :item => x, :admin_group => admin_group}
        else
          @count_hash[admin_group.id][:count] += 1
        end
      end
    end unless @items.blank?
  end

end