# -*- encoding:utf-8 -*-
require 'twitter'


class Misc::Tweet < ActiveRecord::Base
  include System::Model::Base

  attr_accessible :body, :tweeting_at, :tweeted_at


  PREFIX = ""
  POSTFIX = ""

  # プレフィックス文字列
  def prefix
    PREFIX
  end
  # ポストフィックス文字列
  def postfix
    POSTFIX
  end


  # 実際のツイート文字列
  def tweet_body
    (prefix.to_s + body.to_s + postfix.to_s)[0,140]
  end

  # つぶやき済みか否か
  def tweeted?
    tweeted_at
  end

  # つぶやきを行っても良いか否か
  def tweeting?
    tweeted? && tweeting_at <= DateTime.now
  end

  # ツイート待ち状態のツイートを取得
  scope :tweeting, ->(){
    where( Misc::Tweet.arel_table[:tweeting_at].lteq(DateTime.now).and( Misc::Tweet.arel_table[:tweeted_at].eq(nil) ) )
  }

  # 新しいツイートを作成し、つぶやきを予約する
  def self.reserve(body, tweeting_at = DateTime.now)
    tweet = self.new
    tweet.body = body
    tweet.tweeting_at = tweeting_at
    tweet.tweeted_at = nil
    if tweet.save
      return tweet.id
    end
    return nil
  end


  # 待ち状態のツイートのつぶやきを実行する
  def self.tweet_all
    key = Application.config(:tweet_consumer_key, nil)
    secret = Application.config(:tweet_consumer_secret, nil)
    token =Application.config(:tweet_oauth_token, nil)
    token_secret = Application.config(:tweet_oauth_token_secreat, nil)
    return false if key.blank? || secret.blank? || token.blank? || token_secret.blank?
    ret = {:consumer_key => key, :consumer_secret => secret,
      :oauth_token => token, :oauth_token_secret => token_secret}

    client = Twitter::Client.new(
      :consumer_key => key, :consumer_secret => secret,
      :oauth_token => token, :oauth_token_secret => token_secret,
    )
    self.tweeting.each_with_index{|tw, ind|
      tw.tweet(client)
    }
  end

  # ツイートする
  def tweet(client)
    begin
      ret = client.update(self.tweet_body)
      self.tweeted_at = DateTime.now
      self.save!
    rescue => ex
      dump "Twitter投稿エラー #{ex}"
      # 過去数件以内と同じ投稿をするとエラーが帰ってくる。
      # その他エラーを握りつぶし、次回以降ツイートを再度試みる
    end
  end

end
