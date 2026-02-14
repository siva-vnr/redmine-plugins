class AddCountsToTacticalMeetingResponses < ActiveRecord::Migration[5.2]
  def change
    add_column :tactical_meeting_responses, :break_down_count, :integer, default: 0
    add_column :tactical_meeting_responses, :break_through_count, :integer, default: 0
  end
end
