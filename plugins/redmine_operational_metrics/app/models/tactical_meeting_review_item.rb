class TacticalMeetingReviewItem < ActiveRecord::Base
  belongs_to :tactical_meeting_review
  belongs_to :kra, optional: true

  validates :kra_name, presence: true
  validates :weight, presence: true, numericality: true
  validates :score, presence: true, numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: 100 }
end
