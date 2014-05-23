# -*- encoding:utf-8 -*-
require 'open-uri'
require 'rss/1.0'
require 'rss/dublincore'

class Misc::FeedItem < ActiveRecord::Base
  include System::Model::Base
  # author              記事作成者
  # title               記事タイトル
  # url                 記事URL
  # published_at        記事公開（更新）日時
  # genge01 ~ genge03   分野
  # feed_history        どの記事取り込みタイミングで取り込まれたか
  belongs_to :feed_history
  attr_accessible :author, :published_at, :title, :url
  validates :url,              :presence => true

  validates_uniqueness_of :url, :scope => [:title]

  # 分野格納用カラムが増えた場合はここに追加
  GENRES = [:genre01, :genre02, :genre03]
  attr_accessible *GENRES

  # 特定の分野をもつ一覧
  scope :has_genre, ->(genre){
    where( GENRES.inject(arel_table[:id].eq(0)){|acc,c| acc.or(arel_table[c].eq(genre)) } )
  }


  # CategoryのLebelから分野を切り出す正規表現
  def self.regex_for_genre
    /^分野\/(.+)[\/^]/
  end

  # 有効な分野文字列の配列を取得
  def genres
    GENRES.map{|g| self.send(g) }.select{|ge| ge != nil || ge != "" }.compact
  end

  # AtomフィードのItemからFeedを作成する
  def self.create_by_atom_item(item, category_conf=nil)
    obj = self.new
    obj.title = item.methods.include?(:title) ? item.title.content : ""
    obj.url = item.methods.include?(:link) ? item.link.href : ""
    obj.author = item.methods.include?(:author) ? item.author.methods.include?(:name) ? item.author.name.content : "" : ""
    obj.published_at = item.methods.include?(:updated) ? item.updated.content : DateTime.now

    cats = (item.methods.include?(:categories) ? item.categories.map{|cat| cat } : item.methods.include?(:category) ? [item.category] : []).map{|cat|
      cat.label.match(self.regex_for_genre)
    }.compact.map{|m| m[1] }.uniq
    if category_conf.blank?
      GENRES.each.with_index{|g, i| obj.send("#{g.to_s}=".to_sym, cats[i]) if cats.length > i }
    else
      obj.genre01 = category_conf
    end


    return obj
  end

end
