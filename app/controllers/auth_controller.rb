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
        session = JWTSessions::Session.new(payload: payload)
        render json: session.login, status: :accepted
      else
        render json: { error: 'Invalid user'} , status: :unauthorized
      end
    else
      render json: { error: "Missing either email or password parameters" }, status: :bad_request
    end
  end

  def destroy
      session = JWTSessions::Session.new(payload: payload)
      session.flush_by_access_payload
      render json: { status: :ok }, status: :ok
  end

  # def destroy_by_refresh
    # session = JWTSessions::Session.new(payload: payload)
    # session.flush_by_token(found_token)
    # render json: { status: :ok }, status: :ok
  # end

  private

  def not_found
    render json: { error: "Cannot find email/password combination"}, status: :not_found
  end
end
