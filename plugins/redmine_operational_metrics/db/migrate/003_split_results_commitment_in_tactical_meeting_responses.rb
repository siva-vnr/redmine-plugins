class SplitResultsCommitmentInTacticalMeetingResponses < ActiveRecord::Migration[5.2]
  def change
    rename_column :tactical_meeting_responses, :results_commitment, :different_from_my_end
    add_column :tactical_meeting_responses, :get_done_by_when, :text
  end
end
