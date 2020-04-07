class RecoveryMailer < ApplicationMailer
  def new_recovery_email
    @user_name = 'change me'
    @recovery_link = 'change_me'
    @email = params[:email]
    @token = payload['token']
    @csrf = payload['csrf']
    mail(to: ENV['MAILER_EMAIL'], subject: 'Password Recovery.') 
  end
end
