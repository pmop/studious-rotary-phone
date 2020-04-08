class RecoveryMailer < ApplicationMailer
  def new_recovery_email
    @email = params[:email]
    @csrf = params[:tokens][:csrf]
    @access = params[:tokens][:access]
    @user_name = User.where(email: @email).first.name

    mail(to: @email, subject: 'Password Recovery.') 
    
  end
end
