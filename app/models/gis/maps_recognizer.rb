# encoding: utf-8
class Gis::MapsRecognizer < ActiveRecord::Base
  include System::Model::Base
  include System::Model::Base::Config
  include System::Model::Operator

  belongs_to   :user,  :foreign_key => :user_id,  :class_name => 'System::User'
  belongs_to   :portal, :foreign_key => :portal_id, :class_name => 'Gis::Map'

  def is_recognized
    return false if recognized_at.blank?
    return true
  end

  def recognize_state_show
    return "承認済" if is_recognized == true
    return "未承認"
  end

  def save_with_rels(par_items)
    self.errors.add :base , "ユーザが選択されていません。" if par_items[:users].blank?
    recog_map = Gis::Map.where(:id => self.portal_id).first
    self.errors.add :base , "対象となる地図のレコードが存在しません。" if recog_map.blank?
    return false if self.errors.size > 0
    recog_map.web_state = "recognize"
    recog_map.save(:validate=>false)

    mail_title = self.recognize_mail_title
    mail_body = self.recognize_mail_body

    del_items = Gis::MapsRecognizer.find(:all, :conditions=>["portal_id = ?",self.portal_id])
    par_items[:users].each do |p_user|
      next if p_user.blank?
      rec_item = Gis::MapsRecognizer.where(:portal_id => self.portal_id, :user_id => p_user).first
      if rec_item.blank?
        new_rec_item = Gis::MapsRecognizer.new
        new_rec_item.portal_id = self.portal_id
        new_rec_item.user_id = p_user
        new_rec_item.save(:validate=>false)
        new_rec_item.send_mail_to_recognizer(mail_title, mail_body)
      else
        del_items.each_with_index {|del, i|
          del_items.delete_at(i) if del.user_id == rec_item.user_id
        } unless del_items.blank?
        next
      end
    end
    del_items.each{|del|
       if del.user.blank?
         del.destroy
       else
         del.destroy if del.user.auth_no != 4
       end
    } unless del_items.blank?
    recog_admin = System::User.find(:first, :conditions=>["auth_no = ?", 4])
    if recog_admin
      admin_recognition = Gis::MapsRecognizer.find(:first, :conditions=>["portal_id = ? and user_id = ?",self.portal_id, recog_admin.id])
      if admin_recognition.blank?
        new_rec_item = Gis::MapsRecognizer.new
        new_rec_item.portal_id = self.portal_id
        new_rec_item.user_id = recog_admin.id
        new_rec_item.save(:validate=>false)
        new_rec_item.send_mail_to_recognizer(mail_title, mail_body)
      end
    end
    return true
  end

  def recognize_mail_title
    mail_title = "#{self.portal.title}公開承認依頼"
    return mail_title
  end

  def recognize_mail_body
    mail_body = "#{self.portal.title}の公開承認依頼が届いています。\n\n以下のURLから内容を確認し、公開承認を行ってください。\n"
    mail_body +="#{Core.full_uri}/_admin/gis/maps/#{self.portal.id}"
    mail_body += "\n\nこのメールアドレスは送信専用です。"
    return mail_body
  end

  def send_mail_to_recognizer(mail_title, mail_body)
    begin
        mail_title = self.recognize_mail_body if mail_title.blank?
        mail_body = self.recognize_mail_body if mail_body.blank?
        mail_sender = Application.config(:recognize_sender, "JoruriMaps <joruri-maps@localhost>")
        mail_to = self.user.email
        RecognizeNotifier.notify(mail_title, mail_body, mail_sender, mail_to).deliver
    rescue
    end
  end

end
