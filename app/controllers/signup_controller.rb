class SignupController < ApplicationController
  def create
    params[:name].strip! if params[:name].kind_of? String
    params[:email].strip! if params[:email].kind_of? String

    user = User.new(user_params)
    if user.save
      render json: { user: user.to_json }, status: :created
    else
      render json: { error: user.errors.full_messages.join(' '),
                     status: :unprocessable_entity }
    end
  end

  private
  def user_params
    params.permit(:name, :email, :password)
  end
end
