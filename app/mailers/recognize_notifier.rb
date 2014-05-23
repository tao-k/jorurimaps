class RecognizeNotifier < ActionMailer::Base
  default from: "from@example.com"

  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.bbsnotifier.notify.subject
  #
  def notify(title, body, sender, mail_to)
    @body = body
    subject = title
    to = mail_to
    return if to.blank?
    return if sender.blank?
    mail(to: to, subject: subject, from: sender, body: body)
  end

end

