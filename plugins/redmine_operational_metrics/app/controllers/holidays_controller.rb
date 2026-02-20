class HolidaysController < ApplicationController
  before_action :require_login

  def index
    @today = Date.today
    @current_month = params[:month] ? Date.parse(params[:month]) : @today.beginning_of_month
    @next_month = @current_month.next_month
    
    @holidays = Holiday.where("holiday_date >= ? AND holiday_date <= ?", 
                               @current_month.beginning_of_month, 
                               @next_month.end_of_month).pluck(:holiday_date)
  end

  def create
    @holiday = Holiday.new(holiday_params)
    if @holiday.save
      render json: { status: 'success' }
    else
      render json: { status: 'error', errors: @holiday.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def destroy
    @holiday = Holiday.find_by(holiday_date: params[:id])
    if @holiday&.destroy
      render json: { status: 'success' }
    else
      render json: { status: 'error' }, status: :unprocessable_entity
    end
  end

  private

  def holiday_params
    params.require(:holiday).permit(:holiday_date)
  end
end
