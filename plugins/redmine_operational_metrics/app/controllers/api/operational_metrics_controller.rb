module Api
  class OperationalMetricsController < ApplicationController
    before_action :require_login
    accept_api_auth :index, :show, :create, :update, :destroy
    skip_before_action :verify_authenticity_token, if: -> { request.format.json? }
    before_action :find_operational_metric, only: [:show, :update, :destroy]

    def index
      @operational_metrics = OperationalMetric.all
      
      if !User.current.admin?
        @operational_metrics = @operational_metrics.where(user_name: User.current.login)
      end

      if params[:team].present?
        @operational_metrics = @operational_metrics.where(team: params[:team])
      end

      render json: @operational_metrics
    end

    def show
      render json: @operational_metric
    end

    def create
      @operational_metric = OperationalMetric.new(operational_metric_params)
      @operational_metric.user_name = User.current.login if @operational_metric.user_name.blank?

      if @operational_metric.save
        render json: @operational_metric, status: :created
      else
        render json: { errors: @operational_metric.errors.full_messages }, status: :unprocessable_entity
      end
    end

    def update
      if @operational_metric.update(operational_metric_params)
        render json: @operational_metric
      else
        render json: { errors: @operational_metric.errors.full_messages }, status: :unprocessable_entity
      end
    end

    def destroy
      @operational_metric.destroy
      head :no_content
    end

    private

    def find_operational_metric
      @operational_metric = OperationalMetric.find(params[:id])
    rescue ActiveRecord::RecordNotFound
      render json: { error: 'Operational Metric not found' }, status: :not_found
    end

    def operational_metric_params
      params.require(:operational_metric).permit(:task_id, :project, :task_planed, :task_date, :spent_time, :spent_detail, :collaborate_with, :completion, :team, :user_name)
    end
  end
end
