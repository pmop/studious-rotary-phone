module Api
  module V1
  end
end
class Api::V1::UsersController < ApplicationController
  before_action :authorize_access_request!
  before_action :set_user

  def index
    if @user
      safe_json_response
    else
      not_found_or_unauthorized
    end
  end

  def update
    if @user
      params[:email].strip! if params[:email].kind_of? String
      params[:name].strip! if params[:name].kind_of? String
      new_vals = user_params
      logger.info "#{new_vals}"
      unless new_vals.empty?
        if @user.update(new_vals)
          safe_json_response(:accepted)
        else
          render json: { error: @user.errors }, status: :unprocessable_entity
        end
      else
        # Not updated
          render json: { error: 'Bad request' }, status: :bad_request
      end
    else
      not_found_or_unauthorized
    end
  end

  def destroy
    @user.destroy
    session = JWTSessions::Session.new(payload: payload)
    session.flush_by_access_payload
    render json: { status: 'User deleted' }, status: :ok
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_user
      @user = User.find_by_id payload['user_id']
      logger.info "Found user? #{!@user.nil?}. id: #{payload['user_id']}"
    end

    def user_params
      email = params.fetch(:email, nil)
      name = params.fetch(:name, nil)
      password = params.fetch(:password, nil)

      new_vals = {}

      new_vals[:password] = password if !password.nil?
      new_vals[:email] = email if !email.nil?
      new_vals[:name] = name if !name.nil?

      new_vals
    end

    # Don't give information such as id and password
    def safe_json_response(status = :ok)
      render json: { name: @user.name, email: @user.email,
                     created_at: @user.created_at,
                     updated_at: @user.updated_at }, status: status 
    end

    def not_found_or_unauthorized
      render json: { error: "Couldn't find user or unauthorized" }, status: :unauthorized
    end
end
