class GenerateTacticalMeetingSummaryJob < ActiveJob::Base
  queue_as :default

  def self.generating_key(meeting_id)
    "tactical_meeting_summary/#{meeting_id}/generating"
  end

  def self.error_key(meeting_id)
    "tactical_meeting_summary/#{meeting_id}/error"
  end

  def perform(meeting_id)
    tactical_meeting = TacticalMeeting.find_by(id: meeting_id)
    return if tactical_meeting.nil? || tactical_meeting.summary.present?

    summary = TacticalMeetingSummaryGenerator.new(tactical_meeting).generate
    tactical_meeting.update_column(:summary, summary)
    Rails.logger.info "[TacticalMeetingSummary] meeting #{meeting_id}: summary saved (#{summary.length} chars)"
  rescue TacticalMeetingSummaryGenerator::Error => e
    Rails.logger.error "[TacticalMeetingSummary] meeting #{meeting_id}: #{e.message}"
    Rails.cache.write(self.class.error_key(meeting_id), e.message, expires_in: 1.day)
  ensure
    Rails.cache.delete(self.class.generating_key(meeting_id))
  end
end
