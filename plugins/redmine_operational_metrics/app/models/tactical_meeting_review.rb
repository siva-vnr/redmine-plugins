class TacticalMeetingReview < ActiveRecord::Base
  belongs_to :tactical_meeting_response
  belongs_to :reviewer, class_name: 'User'
  has_many :tactical_meeting_review_items, dependent: :destroy, autosave: true

  validates :role, presence: true, inclusion: { in: Kra::ROLES }
  validates :tactical_meeting_response_id, uniqueness: true

  before_save :compute_overall_score

  private

  def compute_overall_score
    self.overall_score = tactical_meeting_review_items.sum do |item|
      item.score.to_f * item.weight.to_f / 100.0
    end.round(2)
  end
end
