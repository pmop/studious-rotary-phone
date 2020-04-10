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
    else
      @reports = Report.all
    end

    # sort_by is present
    if not params[:sort_by].blank?
      order = :desc
      case params[:order]
      when 'asc'
        order = :asc
      end
      case params[:sort_by]
      when 'creation'
        @reports = @reports.sort_by_creation(order)
      when 'updated'
        @reports = @reports.sort_by_update(order)
      end
      # if something weird, do nothing
    end

    render json: @reports.map.with_index { |report, i| JSON.generate(report
      .as_filtered_hash.merge({ 'pos' => i})) }, status: :ok
  end

  # GET /reports/1
  def show
    render json: @report.as_json, status: :ok
  end

  # POST /reports
  def create
    desc, lat, lng = params.require(%i[description lat lng])
    @report = Report.new(description: desc,
                         lat: lat,
                         lng: lng,
                         user_id: @user.id)
    if @report.save
      render json: ( @report.as_json ), status: :created
    else
      render json: { error: @report.errors }, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /reports/1
  def update
    params = reports_params 
    unless params.empty?
      if @report.update(params)
        render json: @report.as_json, status: :ok
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

    def reports_params
      require_optional :description, :lat, :lng, :response
    end
end
