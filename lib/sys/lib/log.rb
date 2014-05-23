# encoding: utf-8
module Sys::Lib::Log
  def log_file(options = {})
    return false unless self.content

    time     = options[:time] || Time.now
    date     = time.strftime('%Y/%m/%d/')
    content  = self.content
    content  = sprintf('%08d', content) if content.to_s =~ /^[0-9]+$/
    log_file = Rails.root.to_s + '/log/access/access/' + date + content + '.log'
  end

  def puts_log(message, options = {})
    unless log = log_file(options)
      return false
    end
    dir = File.dirname(log)
    FileUtils.mkdir_p(dir) unless FileTest.exist?(dir)

    f = File.open(log, 'a')
    f.flock(File::LOCK_EX)
    f.puts message
    f.flock(File::LOCK_UN)
    f.close
  end
end