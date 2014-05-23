# encoding: utf-8
class System::Script::GroupChange
  
  def self.execute
    item = System::GroupChange.new
    item.and :change_at, '<', Time.now
    item.order :company_id
    items = item.find(:all)
    
    puts "所属変更処理 開始 #{items.count}件"
    
    count = {:success => 0, :failure => 0}
    items.each do |item|
      begin
        ActiveRecord::Base.transaction do
          unless item.execute
            raise ActiveRecord::RecordInvalid.new(item)
          end
          unless item.destroy
            raise ActiveRecord::RecordInvalid.new(item)
          end
        end
        count[:success] += 1
      rescue => e
        error_log e.to_s
        count[:failure] += 1
      end
    end
    
    puts "所属変更処理 成功 #{count[:success]}件"
    puts "所属変更処理 失敗 #{count[:failure]}件" if count[:failure] != 0
  end
end