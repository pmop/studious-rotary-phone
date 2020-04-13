module Pmop
  class ResetPasswordError < StandardError
  end
end
class ApplicationController < ActionController::API
  include JWTSessions::RailsAuthorization
  rescue_from JWTSessions::Errors::Unauthorized, with: :not_authorized
  rescue_from Pmop::ResetPasswordError, with: :not_authorized
  rescue_from ActiveRecord::RecordNotFound, with: :not_found
  rescue_from ArgumentError, with: :bad_request

  rescue_from ActionController::ParameterMissing do |ex|
    missing_params ex.message
  end

  def strip_whitespace
    params[:partner].each do |key, value|
      value.strip! unless (value.nil? or value.kind_of?(Array) )
    end
  end

  def require_optional (*args)
      _fetch = {}

       args.each do |arg|
        _fetch[arg] = params.fetch(arg, nil)
      end

      _fetch.compact
  end

  private

  def json_response(error, status)
    render json: { error: error }, status: status
  end

  def current_user
    @current_user ||= User.find(payload['user_id'])
  end

  def not_authorized
    json_response 'Not authorized', :unauthorized
  end

  def bad_request
    json_response 'Bad request', :bad_request
  end

  def missing_params(error)
    json_response error, :unprocessable_entity
  end

  def not_found
    json_response 'Not found', :not_found
  end
end
