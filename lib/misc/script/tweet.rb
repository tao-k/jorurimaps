# -*- encoding: utf-8 -*-
class Misc::Script::Tweet

  def self.reserve_tweet_test
    Misc::Tweet.reserve("つぶやきテストなう#{rand(1000)}")
  end

  def self.list_reserved_tweets
    Misc::Tweet.tweeting.each{|tw| puts tw.tweet_body }
  end

  def self.tweet_all
    dump "#{Time.now} Twitter投稿"
    Misc::Tweet.tweet_all
    dump "#{Time.now} Twitter投稿終了"
  end

  def self.test
    reserve_tweet_test
    list_reserved_tweets
    tweet_all
  end
end