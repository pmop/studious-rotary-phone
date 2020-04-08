class RecoveryController < ApplicationController
  before_action :authorize_access_request!, only: [:index]

  #/recovery/csrf=''&access=''
  # Set response cookies for csrf and token sent to user's email
  def create
    begin
      @access,@csrf = recovery_params
      tokens  = {}
      tokens[:access] = @access
      tokens[:csrf] = @csrf

    rescue ActionController::ParameterMissing => e
      render json: { error: "#{e}" }, status: :bad_request
    else
      response.set_cookie(JWTSessions.access_cookie,
                          value: tokens[:access],
                          httponly: true,
                          secure: Rails.env.production?)
      render json: { csrf: @csrf }, status: :ok
    end
  end

  def index
    # Destroy recovery session created from token sent to user's email
    logger.debug "#{Time.now} Recovery#index PAYLOAD: #{payload}"
    session = JWTSessions::Session.new(payload: payload)
    user = User.find_by_id payload['user_id']
    session.flush_by_access_payload
    # And create a new working session so user can reset
    # his password if he wishes
    payload = { user_id: user.id }
    session = JWTSessions::Session.new(payload: payload,
                                       refresh_by_access_allowed: true)
    tokens = session.login
    response.set_cookie(JWTSessions.access_cookie,
                        value: tokens[:access],
                        httponly: true,
                        secure: Rails.env.production?)
    render json: { status: 'Recovery session', csrf: tokens[:csrf] },
      status: :accepted   
  end

  # POST /reset_password/:email
  def reset_password
    if params[:email].present?
      email = params[:email].strip if params[:email].kind_of? String
      user = User.find_by_email email 
      if user
        payload = { user_id: user.id }
        session = JWTSessions::Session.new(payload: payload,
                                           refresh_by_access_allowed: true,
                                           access_exp: 10.minutes.from_now)
        tokens = session.login
        # But here we wont give tokens to user, we'll send to his email

         RecoveryMailer.with(email: params[:email],
                           tokens: tokens)
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

  def recovery_params
    params.require([:access, :csrf])
  end
end
