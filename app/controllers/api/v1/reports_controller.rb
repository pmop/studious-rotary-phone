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

    elsif params[:newest_first].eql? 'true'
      @reports = Report.newest_first

    elsif params[:oldest_first].eql? 'true'
      @reports = Report.oldest_first

    elsif params[:updated_recently].eql? 'true'
      @reports = Report.updated_recently

    elsif params[:updated_oldest].eql? 'true'
      @reports = Report.updated_oldest

    else
      @reports = Report.all
    end

    render json: @reports.map { |report| default_report_hash report }, status: :ok
  end

  # GET /reports/1
  def show
    render json: (default_report_hash @report), status: :ok
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
        render json: (default_report_hash @report), status: :created
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
    report_params = reports_optional_params 

    unless report_params.empty?
      report_params[:status] = 'edited' if report_params[:response].nil?

      user = User.find_by_id params[:user_id]
      @report.user ||= user

      if @report.update(report_params)
        render json: (default_report_hash @report), status: :ok
      else
        render json: { error: @report.errors }, status: :unprocessable_entity
      end
    else
      render json: { error: 'Bad request' }, status: :bad_request
    end
  end

  # DELETE /reports/1
  def destroy
    @report.destroy
    render json: { status: 'Report destroyed' }, status: :ok
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_report
      @report = Report.find(params[:id])
    end

    def set_user
      @user = User.find_by_id payload['user_id']
    end

    def mandatory_create_params
      %i[description lat lng]
    end

    # Optional parameters user can enter to update
    def reports_optional_params
      new_vals = {
        description: params.fetch(:description, nil),
        lat: params.fetch(:lat, nil),
        lng: params.fetch(:lng, nil),
        response: params.fetch(:response, nil)
      }
      new_vals[:status] = 'replied' if !new_vals[:response].nil?

      new_vals.compact
    end

    def default_report_hash(report)
      {
        status: report.status,
        description: report.description,
        user_name: report.user.name ,
        user_email: report.user.email,
        lat: report.lat,
        lng: report.lng,
        response: report.response,
        created_at: report.created_at,
        updated_at: report.updated_at
      }
    end
end
