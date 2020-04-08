class RecoveryController < ApplicationController
  before_action :authorize_access_request!, only: [:index]
  before_action :set_user, only: [:create]

  #/recovery/csrf=''&access=''
  # Set response cookies for csrf and token sent to user's email
  def create
    payload = { user_id: @user.id }
    session = JWTSessions::Session.new(payload: payload,
                                       refresh_by_access_allowed: true)
    tokens = session.login
    response.set_cookie(JWTSessions.access_cookie,
                          value: tokens[:access],
                          httponly: true,
                          secure: Rails.env.production?)
    render json: { status: 'Use this session to reset your password',
                   csrf: tokens[:csrf] }, status: :accepted   
  end

  # POST /reset_password/:email
  def reset_password
    if params[:email].present?
      email = params[:email].strip if params[:email].kind_of? String
      user = User.find_by_email email 
      if user
        user.generate_password_token!
        RecoveryMailer.with(email: params[:email],
                           user: user)
                          .new_recovery_email.deliver_later
        render json: { status: "Recovery email sent to #{params[:email]}" }, status: :accepted
      else
        # We should never give out if the email exists in the database
        logger.warn "#{email} not found in the database."
        # So we send the same response as successful
        render json: { status: "Recovery email sent to #{params[:email]}" }, status: :accepted
      end
    else
      render json: { error: 'Bad request' }, status: :bad_request
    end
  end

  private

  def set_user
    @user = User.find_by reset_password_token: params.require(:token)
    raise Pmop::ResetPasswordError unless @user&.reset_password_token_expires_at &&
      @user.reset_password_token_expires_at > Time.now
  end
end
