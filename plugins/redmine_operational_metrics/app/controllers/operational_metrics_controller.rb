class OperationalMetricsController < ApplicationController
  before_action :find_operational_metric, only: [:show, :edit, :update, :destroy]
  before_action :require_admin, only: [:edit, :update, :destroy]

  def stats
    @last_working_day = find_last_working_day(Date.today)
    
    if params[:date_from].blank? && params[:date_to].blank?
      params[:date_from] = @last_working_day
      params[:date_to] = @last_working_day
    end

    @metrics = OperationalMetric.all
    if !User.current.admin?
      @metrics = @metrics.where(user_name: User.current.login)
    end

    @projects = @metrics.distinct.pluck(:project).sort
    @users = @metrics.distinct.pluck(:user_name).sort

    if params[:date_from].present?
      @metrics = @metrics.where('task_date >= ?', params[:date_from])
    end

    if params[:date_to].present?
      @metrics = @metrics.where('task_date <= ?', params[:date_to])
    end

    if params[:project].present?
      @metrics = @metrics.where(project: params[:project])
    end

    if params[:user_name].present?
      @metrics = @metrics.where(user_name: params[:user_name])
    end
    
    @completion_counts = @metrics.group(:completion).count
    @project_counts = @metrics.group(:project).count
    
    @todays_metrics = OperationalMetric.where(task_date: @last_working_day)
    if !User.current.admin?
      @todays_metrics = @todays_metrics.where(user_name: User.current.login)
    end

    if params[:project].present?
      @todays_metrics = @todays_metrics.where(project: params[:project])
    end

    if User.current.admin? && params[:user_name].present?
      @todays_metrics = @todays_metrics.where(user_name: params[:user_name])
    end
    
    @total_spent_minutes = if !User.current.admin? || params[:user_name].present?
                             @metrics.sum(:spent_time) || 0
                           else
                             nil
                           end
  end

  def index
    scope = OperationalMetric.all

    if !User.current.admin?
      scope = scope.where(user_name: User.current.login)
    end

    if params[:date_from].present?
      scope = scope.where('task_date >= ?', params[:date_from])
    end

    if params[:date_to].present?
      scope = scope.where('task_date <= ?', params[:date_to])
    end

    @operational_metrics = scope
    @total_spent_minutes = if !User.current.admin? || params[:user_name].present?
                             scope.sum(:spent_time) || 0
                           else
                             nil
                           end
  end

  def show
  end

  def new
    @operational_metric = OperationalMetric.new
  end

  def create
    @operational_metric = OperationalMetric.new(operational_metric_params)
    if @operational_metric.save
      flash[:notice] = 'Operational Metric successfully created.'
      redirect_to operational_metrics_path
    else
      render :new
    end
  end

  def edit
  end

  def update
    if @operational_metric.update(operational_metric_params)
      flash[:notice] = 'Operational Metric successfully updated.'
      redirect_to operational_metrics_path
    else
      render :edit
    end
  end

  def destroy
    @operational_metric.destroy
    flash[:notice] = 'Operational Metric successfully deleted.'
    redirect_to operational_metrics_path
  end

  private

  def find_last_working_day(date)
    d = date - 1
    while Holiday.exists?(holiday_date: d)
      d -= 1
    end
    d
  end

  def find_operational_metric
    @operational_metric = OperationalMetric.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    render_404
  end

  def operational_metric_params
    params.require(:operational_metric).permit(:task_id, :user_name, :project, :task_planed, :task_date, :spent_time, :spent_detail, :collaborate_with, :completion)
  end
end
