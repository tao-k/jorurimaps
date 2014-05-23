# -*- encoding: utf-8 -*-
require 'open-uri'
require 'rss/1.0'
require 'rss/dublincore'


class Misc::FeedHistory < ActiveRecord::Base
  include System::Model::Base
  # count              取り込み記事数
  # requested_at       記事URL
  # publisher_name     フィード公開者名
  attr_accessible :count, :publisher_name, :requested_at

  # 指定したURLアドレスのAtomフィードから取り込み対象記事情報を取り込んで永続化する
  def self.import_from_atom(publisher_name, address, category=nil)
    feed = open(address){|file| RSS::Parser.parse(file.read) }
    feed.output_encoding = "UTF-8"

    last_imported_at = self.where(arel_table[:publisher_name].eq(publisher_name)).maximum(:requested_at)
    items = feed.entries.map{|item| Misc::FeedItem.create_by_atom_item(item, category) }.select{|item| !last_imported_at || item.published_at > last_imported_at }

    fh = self.new
    fh.publisher_name = publisher_name
    fh.requested_at = DateTime.now
    fh.count = items.length
    fh.save!

    items.each{|item| item.feed_history_id = fh.id; item.save }
  end


  def parent_category_select(options={})
    if options[:include_blank]
      ret = [["なし",nil]]
    else
      ret = []
    end
    ret = ret.concat(Gis.yaml_to_array_for_select("gis_map_parent_category"))
    return ret
  end

  def cache_clear
    parent_category_select.each do |category|
      Rails.cache.delete "feed_index_#{category[1]}"
    end
  end

end
