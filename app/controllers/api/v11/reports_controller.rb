module Api
  module V11
  end
end
class Api::V11::ReportsController < ApplicationController
  # Takes care of authentication.
  before_action :authorize_access_request!
  before_action :set_report, only: %i[show update destroy]
  # Gets the current user for us. Just for convenience.
  before_action :set_user, only: %i[create update]

  # GET /reports
  def index

    # Look for limit param and set to 50 if not found
    limit_to = params.fetch(:limit, 50)
    limit_to = limit_to.to_i
    limit_to = 50 if limit_to <= 0
    limit_to = 100 if limit_to > 100

    reports_size = Report.count
    even = reports_size%limit_to == 0
    even.freeze
    pages = reports_size/limit_to

    correction = 1
    case (not even)
    when true
      pages = pages + 1
    else
      correction = 0
    end
    pages.freeze

    # Search for page param and default to 1
    page = params.fetch(:page, 1)
    page = page.to_i 

    case 
    when page <= 0
      page = 1
    when page > pages
      page = pages
    end
    page.freeze

    
    offset = 0
    offset = (page - correction)*limit_to if page > 1

    if params[:description].present? and !params[:page].present?
      @reports = Report.search(params[:description])
        .limit(limit_to)
        .offset(offset)
    else
      @reports = Report.all
        .limit(limit_to)
        .offset(offset)
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

    response = { page: page,
                 pages: pages,
                 reports: @reports
      .map
      .with_index { |report, i|
        report
        .as_filtered_hash.merge({ 'pos' => i})
      }
    }

    render json: response, status: :ok
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
