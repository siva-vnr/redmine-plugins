class HolidaysController < ApplicationController
  before_action :require_login

  def index
    @today = Date.today
    @current_month = params[:month] ? Date.parse(params[:month]) : @today.beginning_of_month
    @next_month = @current_month.next_month
    
    populate_weekends_if_empty(@current_month)
    populate_weekends_if_empty(@next_month)

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

  def populate_weekends_if_empty(month)
    start_date = month.beginning_of_month
    end_date = month.end_of_month
    
    unless Holiday.where("holiday_date >= ? AND holiday_date <= ?", start_date, end_date).exists?
      (start_date..end_date).each do |date|
        if date.saturday? || date.sunday?
          Holiday.create(holiday_date: date)
        end
      end
    end
  end

  def holiday_params
    params.require(:holiday).permit(:holiday_date)
  end
end
