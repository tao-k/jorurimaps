# encoding: utf-8
module System::Controller::Admin::GroupSelect


  def get_info
    g_id = params[:g_id].to_i
    @item = System::Group.where(:id => g_id).first
    xml_select = Builder::XmlMarkup.new :indent => 2
    xml_obj = xml_select.items{
      if @item
        xml_select.item{
          xml_select.mail_addr(@item.email)
          #xml_select.tel(value)
          #xml_select.fax(value)
        }
      end
    }
    respond_to do |format|
      format.xml { render :xml => xml_obj }
    end
  end
end