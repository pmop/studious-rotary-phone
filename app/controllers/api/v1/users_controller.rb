module Api
  module V1
  end
end
class Api::V1::UsersController < ApplicationController
  before_action :authorize_access_request!
  before_action :set_user

  def index
    if @user
      render json: @user.as_json, status: :ok
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
          render json: @user.as_json, status: :ok
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
    render json: { status: 'Deleted' }, status: :ok
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_user
      @user = User.find_by_id payload['user_id']
      logger.info "Found user? #{!@user.nil?}. id: #{payload['user_id']}"
    end

    def user_params
      require_optional :email, :name, :password
    end

    def not_found_or_unauthorized
      render json: { error: "Couldn't find user or unauthorized" }, status: :unauthorized
    end
end
