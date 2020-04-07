class AuthController < ApplicationController
  before_action :authorize_access_request!, only: [:destroy]

  def create
    # Make sure email doesn't have trailing whitespace 
    params[:email].strip! if params[:email].kind_of? String

    if params[:email].present? && params[:password].present?
      user = User.find_by(email: params[:email])

      # Short-circuit here
      if !user.nil? && user.authenticate(params[:password])
        payload = { user_id: user.id }
        session = JWTSessions::Session.new(payload: payload,
                                           refresh_by_access_allowed: true)
        tokens = session.login
        response.set_cookie(JWTSessions.access_cookie,
                            value: tokens[:access],
                            httponly: true,
                            secure: Rails.env.production?)
        render json: { csrf: tokens[:csrf] }, status: :accepted
      else
        not_found
      end
    else
      render json: { error: "Missing either email or password parameters" }, status: :bad_request
    end
  end

  def destroy
      session = JWTSessions::Session.new(payload: payload)
      session.flush_by_access_payload
      render json: { status: 'Logged out' }, status: :ok
  end

  private

  def not_found
    render json: { error: "Cannot find email/password combination"}, status: :not_found
  end
end
