# encoding: utf-8
module System::Controller::Admin::UserSelect

  def user_fields
    users = System::User.get_user_select(params[:g_id])
    html_select = ""
    xml_select = Builder::XmlMarkup.new :indent => 2
    xml_obj = xml_select.items{
    users.each do |value , key|
      xml_select.item{
        xml_select.user_id(key)
        xml_select.name(value)
      }
      html_select << "<option value='#{key}'>#{value}</option>"
    end
    }
    respond_to do |format|
      format.csv { render :text => html_select ,:layout=>false ,:locals=>{:f=>@item} }
      format.xml { render :xml => xml_obj }
    end
  end


end