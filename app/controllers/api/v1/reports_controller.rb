module Api
  module V1
  end
end
class Api::V1::ReportsController < ApplicationController
  before_action :authorize_access_request!
  before_action :set_report, only: %i[show update destroy]
  before_action :set_user, only: %i[create update]

  # GET /reports
  def index
    @reports = Report.all

    render json: @reports, status: :ok
  end

  # GET /reports/1
  def show
    if params[:description].present?
      @reports = Report.search params[:description] 
    end
    render json: @report, status: :ok
  end

  # POST /reports
  def create
    mandatory = mandatory_create_params

    if (params.slice(*mandatory).values.all?(&:present?))
      @report = Report.new(description: params[:description],
                           lat: params[:lat],
                           lng: params[:lng],
                           response: 'waiting',
                           status: 'waiting response')
      @report.user = @user
      if @report.save
        render json: @report, status: :created
      else
        render json: @report.errors, status: :unprocessable_entity
      end
    else
        render json: "Missing mandatory parameters (description, lat, lng)",
          status: :bad_request
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
      user_id = payload['user_id']
      unless user_id
        @user = User.find(user_id).first
      end
    end


    # Only allow a trusted parameter "white list" through.
    def mandatory_create_params
      %i[description lat lng]
    end
end
