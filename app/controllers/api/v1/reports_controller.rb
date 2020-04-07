module Api
  module V1
  end
end
class Api::V1::ReportsController < ApplicationController
  # Takes care of authentication.
  before_action :authorize_access_request!
  before_action :set_report, only: %i[show update destroy]
  # Gets the current user for us. Just for convenience.
  before_action :set_user, only: %i[create update]

  # GET /reports
  def index
    if params[:description].present?
      @reports = Report.search params[:description] 
    elsif params[:newest_first].present? && params[:newest_first] == 'true'
      @reports = Report.newest_first
    elsif params[:oldest_first].present? && params[:oldest_first] == 'true'
      @reports = Report.oldest_first
    elsif params[:updated_recently].present? && 
      params[:updated_recently] == 'true'
      @reports = Report.updated_recently
    elsif params[:updated_oldest].present? && 
      params[:updated_oldest] == 'true'
      @reports = Report.updated_oldest
    else
      @reports = Report.all
    end

    render json: @reports, status: :ok
  end

  # GET /reports/1
  def show
    render json: @report, status: :ok
  end

  # POST /reports
  def create
    mandatory = mandatory_create_params

    if (params.slice(*mandatory).values.all?(&:present?))
      @report = Report.new(description: params[:description],
                           lat: params[:lat],
                           lng: params[:lng],
                           response: '',
                           status: 'new')
      @report.user = @user
      if @report.save
        render json: @report, status: :created
      else
        render json: { error: @report.errors }, status: :unprocessable_entity
      end
    else
        render json: { error: "Missing mandatory parameters 
                       (description, lat, lng)" }, status: :bad_request
    end

  end

  # PATCH/PUT /reports/1
  def update
    if @report.update(report_params)
      render json: @report
    else
      render json: @report.errors, status: :unprocessable_entity
    end
  end

  # DELETE /reports/1
  def destroy
    @report.destroy
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_report
      @report = Report.find(params[:id])
    end

    def set_user
      @user = User.find_by_id payload['user_id']
    end


    # Only allow a trusted parameter "white list" through.
    def mandatory_create_params
      %i[description lat lng]
    end
end
