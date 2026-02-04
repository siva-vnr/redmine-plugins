class TacticalMeetingResponsesController < ApplicationController
  def index
    @tactical_meeting = TacticalMeeting.find(params[:tactical_meeting_id])
    @responses = @tactical_meeting.tactical_meeting_responses.includes(:user)
  end

  def show
    @tactical_meeting_response = TacticalMeetingResponse.find(params[:id])
    @tactical_meeting = @tactical_meeting_response.tactical_meeting
  end

  def new
    @tactical_meeting = TacticalMeeting.find(params[:tactical_meeting_id])
    @tactical_meeting_response = TacticalMeetingResponse.new(tactical_meeting: @tactical_meeting)
    
    # Fetch operational metrics for the current user within the meeting's date range
    @operational_metrics = OperationalMetric.where(
      user_name: User.current.login,
      task_date: @tactical_meeting.start_date..@tactical_meeting.end_date
    )
  end

  def create
    @tactical_meeting = TacticalMeeting.find(params[:tactical_meeting_response][:tactical_meeting_id])
    @tactical_meeting_response = TacticalMeetingResponse.new(tactical_meeting_response_params)
    @tactical_meeting_response.user = User.current
    @tactical_meeting_response.tactical_meeting = @tactical_meeting

    if @tactical_meeting_response.save
      flash[:notice] = "Response submitted successfully."
      redirect_to home_path # Or wherever appropriate
    else
      # Re-fetch metrics for the view
      @operational_metrics = OperationalMetric.where(
        user_name: User.current.login,
        task_date: @tactical_meeting.start_date..@tactical_meeting.end_date
      )
      render :new
    end
  end

  private

  def tactical_meeting_response_params
    params.require(:tactical_meeting_response).permit(
      :tactical_meeting_id,
      :individual_goal,
      :what_was_done,
      :what_not_done,
      :missing_from_my_end,
      :learnings,
      :different_from_my_end,
      :get_done_by_when,
      :next_fortnight_goals,
      :problems_doubts_fears,
      :closure_notes
    )
  end
end
