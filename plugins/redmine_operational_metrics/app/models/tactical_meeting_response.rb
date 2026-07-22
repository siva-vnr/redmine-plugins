class TacticalMeetingResponse < ActiveRecord::Base
  belongs_to :tactical_meeting
  belongs_to :user
  has_one :tactical_meeting_review, dependent: :destroy

  validates :tactical_meeting_id, presence: true
  validates :user_id, presence: true, uniqueness: { scope: :tactical_meeting_id, message: "has already responded to this meeting" }
end
