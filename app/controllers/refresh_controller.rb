class RefreshController < ApplicationController
  before_action :authorize_refresh_by_access_request!

  def create
    session = JWTSessions::Session.new(payload: payload)
    render json: session.refresh(found_token)
  end
end
