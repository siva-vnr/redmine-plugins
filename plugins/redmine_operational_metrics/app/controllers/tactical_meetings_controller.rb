class TacticalMeetingsController < ApplicationController
  before_action :require_admin, except: [:index]

  def index
    @tactical_meetings = TacticalMeeting.all.order(start_date: :desc)
  end

  def new
    @tactical_meeting = TacticalMeeting.new
  end

  def create
    @tactical_meeting = TacticalMeeting.new(tactical_meeting_params)
    if @tactical_meeting.save
      flash[:notice] = "Tactical meeting created successfully."
      redirect_to new_tactical_meeting_path
    else
      render :new
    end
  end

  private

  def tactical_meeting_params
    params.require(:tactical_meeting).permit(:start_date, :end_date, :facilitator)
  end
end
