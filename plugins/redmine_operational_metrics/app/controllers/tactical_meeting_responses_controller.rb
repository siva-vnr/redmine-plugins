class TacticalMeetingResponsesController < ApplicationController
  def index
    @tactical_meeting = TacticalMeeting.find(params[:tactical_meeting_id])
    @responses = @tactical_meeting.tactical_meeting_responses.includes(:user)
    
    unless User.current.admin?
      @responses = @responses.where(user_id: User.current.id)
    end
  end

  def show
    @tactical_meeting_response = TacticalMeetingResponse.find(params[:id])
    @tactical_meeting = @tactical_meeting_response.tactical_meeting

    if !User.current.admin? && @tactical_meeting_response.user_id != User.current.id
      render_403
      return
    end
  end

  def new
    @tactical_meeting = TacticalMeeting.find(params[:tactical_meeting_id])
    @tactical_meeting_response = TacticalMeetingResponse.new(tactical_meeting: @tactical_meeting)
    
    # Fetch operational metrics for the current user within the meeting's date range
    metrics = OperationalMetric.where(
      user_name: User.current.login,
      task_date: @tactical_meeting.start_date..@tactical_meeting.end_date
    )

    # Calculate counts based on unique task_id
    @tactical_meeting_response.break_down_count = metrics.where(completion: 'Break down').pluck(:task_id).uniq.count
    @tactical_meeting_response.break_through_count = metrics.where(completion: 'Break through').pluck(:task_id).uniq.count

    # Filter for display: only unique "Break through" tickets
    @operational_metrics = metrics.where(completion: 'Break through').select('DISTINCT ON (task_id) *').order('task_id, task_date DESC')
    # If using MySQL or SQLite where DISTINCT ON is not available:
    # @operational_metrics = metrics.where(completion: 'Break through').group(:task_id).order('task_date DESC')
    # Since I don't know the DB type, I'll use a more portable approach if possible, or just Ruby filtering if the dataset is small.
    # Let's try to find out the DB type or use a ruby filter for safety.
    @operational_metrics = metrics.where(completion: 'Break breakthrough').to_a.uniq(&:task_id)
    # Actually, let's fix the typo 'Break breakthrough' and use the correct 'Break through'
    @operational_metrics = metrics.where(completion: 'Break through').to_a.uniq(&:task_id)
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
      metrics = OperationalMetric.where(
        user_name: User.current.login,
        task_date: @tactical_meeting.start_date..@tactical_meeting.end_date
      )
      @operational_metrics = metrics.where(completion: 'Break through').to_a.uniq(&:task_id)
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
      :closure_notes,
      :break_down_count,
      :break_through_count
    )
  end
end
