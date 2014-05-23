#ここにはJoruriMapsの固定情報を保存します。
#特定のページ指定用メソッド
#使用法 config_url(:symbol) パスが登録されていればそれを返し、なければ 404.html を返す
def config_url(key=nil)
  url = key.nil? ? JoruriMaps::Application.config.urls : JoruriMaps::Application.config.urls[key]
  return url.nil? ? "/404.html" : url
end

#特定のページ指定
JoruriMaps::Application.config.urls = {
  :config_settings_sakujo => '/gw/config_settings?c1=1&c2=7',
  :config_settings_root => '/gw/config_settings'
}
