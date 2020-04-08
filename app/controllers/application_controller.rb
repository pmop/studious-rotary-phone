module Pmop
  class ResetPasswordError < StandardError
  end
end
class ApplicationController < ActionController::API
  include JWTSessions::RailsAuthorization
  rescue_from JWTSessions::Errors::Unauthorized, with: :not_authorized
  rescue_from Pmop::ResetPasswordError, with: :not_authorized
  rescue_from ActionController::ParameterMissing, with: :bad_request

  def strip_whitespace
    params[:partner].each do |key, value|
      value.strip! unless (value.nil? or value.kind_of?(Array) )
    end
  end

  private

  def current_user
    @current_user ||= User.find(payload['user_id'])
  end

  def not_authorized
    render json: { error: 'Not authorized' }, status: :unauthorized
  end
end
