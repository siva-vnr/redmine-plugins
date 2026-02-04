class TacticalMeeting < ActiveRecord::Base
  has_many :tactical_meeting_responses, dependent: :destroy

  validates :start_date, presence: true
  validates :end_date, presence: true
  validate :end_date_after_start_date

  def to_s
    "#{start_date} - #{end_date}"
  end

  private

  def end_date_after_start_date
    return if end_date.blank? || start_date.blank?

    if end_date < start_date
      errors.add(:end_date, "must be after the start date")
    end
  end
end
