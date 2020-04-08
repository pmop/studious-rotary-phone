class RecoveryMailer < ApplicationMailer
  def new_recovery_email
    user = params[:user]
    @email = user.email
    @user_name = user.name
    @token = user.reset_password_token

    mail(to: @email, subject: 'Password Recovery.') 
    
  end
end
