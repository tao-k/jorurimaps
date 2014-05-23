# encoding: utf-8
class System::Lib::Smtp < ActionMailer::Base

  def simple_mail(options = {})
    mail(
      :from    => options[:from],
      :to      => options[:to],
      :cc      => options[:cc],
      :bcc     => options[:bcc],
      :subject => options[:subject],
      :body    => options[:body],
      :charset => 'iso-2022-jp'
    )
  end
end
