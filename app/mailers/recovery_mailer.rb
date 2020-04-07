class RecoveryMailer < ApplicationMailer
  def new_recovery_email
    @email = params[:email]
    @token = params[:token]
    @csrf = params[:csrf]

    @user_name = User.where(email: @email).first.name
    @recovery_link = 'change_me'
    mail(to: @email, subject: 'Password Recovery.') 
    
  end
end
