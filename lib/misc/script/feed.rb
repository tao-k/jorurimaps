# -*- encoding: utf-8 -*-
class Misc::Script::Feed

  def self.import_rss
    dump "#{Time.now} フィード取り込み開始"
    options = System::Option.where(:kind => "atom_url")
    if options
      options.each do |option|
        next if option.value.blank?
        begin
          ret = option.value.split(/,/)
          name = ret[0]
          address = ret[1]
          next if ret[1].blank?
          category = ret[2]
          Misc::FeedHistory.import_from_atom(name, address,category)
        rescue
          next
        end
      end
      cache_item = Misc::FeedHistory.new
      cache_item.cache_clear
    else
      dump "#{Time.now} フィード取り込み設定なし"
    end
    dump "#{Time.now} フィード取り込み終了"
  end

end