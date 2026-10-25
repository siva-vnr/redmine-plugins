class TacticalMeetingsController < ApplicationController
  before_action :require_admin, except: [:index, :summary]

  def index
    @tactical_meetings = TacticalMeeting.all.order(start_date: :desc)
  end

  def summary
    @tactical_meeting = TacticalMeeting.find(params[:id])
    return if @tactical_meeting.summary.present?

    @generating = Rails.cache.exist?(GenerateTacticalMeetingSummaryJob.generating_key(@tactical_meeting.id))
    @summary_error = Rails.cache.read(GenerateTacticalMeetingSummaryJob.error_key(@tactical_meeting.id))
  end

  def generate_summary
    @tactical_meeting = TacticalMeeting.find(params[:id])
    generating_key = GenerateTacticalMeetingSummaryJob.generating_key(@tactical_meeting.id)

    if @tactical_meeting.summary.blank? && !Rails.cache.exist?(generating_key)
      if TacticalMeetingSummaryGenerator.new(@tactical_meeting).reviews_rows.empty?
        flash[:error] = "No reviews yet for this meeting."
      else
        Rails.cache.delete(GenerateTacticalMeetingSummaryJob.error_key(@tactical_meeting.id))
        Rails.cache.write(generating_key, true, expires_in: 15.minutes)
        GenerateTacticalMeetingSummaryJob.perform_later(@tactical_meeting.id)
        flash[:notice] = "AI summary generation started. Refresh this page in a few minutes."
      end
    end
    redirect_back fallback_location: summary_tactical_meeting_path(@tactical_meeting)
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
