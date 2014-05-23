# encoding: utf-8
require 'rexml/document'
class System::Script::CommunityMail
  include System::Script::Base
  
  def self.send_mail
    return unless self.executable?
    
    item = System::CommunityMail.new
    item.and 'system_community_mails.send_flag', '0'
    item.and 'system_community_mails.send_at', '<', Time.now
    item.and 'system_community_mail_states.ymail_id', 'IS', nil
    item.order 'system_community_mails.send_at'
    items = item.find(:all, :include => :mail_states)
    
    puts "コミュニティメール配信 開始 #{items.count}件"
    
    count = {:success => 0, :failure => 0}
    
    items.each do |item|
      begin
        ActiveRecord::Base.transaction do
          if item.send_mail
            count[:success] += 1
          else
            raise ActiveRecord::RecordInvalid.new(item)
          end
        end
      rescue => e
        count[:failure] += 1
        error_log e.to_s
      end
    end
    
    str =  "コミュニティメール配信 成功 #{count[:success]}件\n"
    str << "コミュニティメール配信 失敗 #{count[:failure]}件" if count[:failure] != 0
    puts str
  end
  
  def self.get_mail_progress
    return unless self.executable?
    
    item = System::CommunityMailState.new
    item.and :ymail_id, 'IS NOT', nil
    item.and :ymail_message, 'Success.'
    item.and do |c|
      c.or :ymail_send_state, 'IS', nil
      c.or :ymail_send_state, 'NOT IN', ['Error.','Done.']
    end
    item.order :created_at
    items = item.find(:all)
    
    puts "コミュニティメール配信状況取得 開始 #{items.count}件"
    
    count = {:success => 0, :failure => 0}
    
    items.each do |item|
      if item.get_mail_progress
        count[:success] += 1
      else
        count[:failure] += 1
      end
    end
    
    puts "コミュニティメール配信状況取得 成功 #{count[:success]}件"
    puts "コミュニティメール配信状況取得 失敗 #{count[:failure]}件" if count[:failure] != 0
  end
end
