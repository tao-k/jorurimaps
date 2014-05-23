# encoding: utf-8
class System::Script::UsersGroupChange
  
  def self.execute
    item = System::UsersGroupChange.new
    item.and :change_at, '<', Time.now
    item.order :company_id
    items = item.find(:all)
    
    puts "異動・退職処理 開始 #{items.count}件"
    
    count = {:success => 0, :failure => 0}
    company_items = items.group_by(&:company_id)
    company_items.each do |company_id, items|
      begin
        ActiveRecord::Base.transaction do
          items.each do |item|
            unless item.execute
              raise ActiveRecord::RecordInvalid.new(item)
            end
          end
          items.each do |item| 
            unless item.destroy
              raise ActiveRecord::RecordInvalid.new(item)
            end
          end
        end
        count[:success] += items.size
      rescue => e
        error_log e.to_s
        count[:failure] += items.size
      end
    end
    
    puts "異動・退職処理 成功 #{count[:success]}件"
    puts "異動・退職処理 失敗 #{count[:failure]}件" if count[:failure] != 0
  end
end
