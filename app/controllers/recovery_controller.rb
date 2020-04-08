class RecoveryController < ApplicationController
  before_action :authorize_access_request!, only: [:index]
  before_action :set_user, only: %i[create update]

  def create
    render json: :ok
  end

  def update
    password, password_confirmation = password_params
    if @user.update({ password: password,
                    password_confirmation: password_confirmation })
    @user.clear_password_token!
    render json: { status: 'Password updated' }, status: :accepted
    else
      render json: { error: @user.errors }, status: :unprocessable_entity,
      location: user_path(@user)
    end
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

  KEYS = [:password, :password_confirmation].freeze

  def password_params
    params.require(KEYS)
  end

  def set_user
    @user = User.find_by reset_password_token: params.require(:token)
    raise Pmop::ResetPasswordError unless @user&.reset_password_token_expires_at &&
      @user.reset_password_token_expires_at > Time.now
  end
end
