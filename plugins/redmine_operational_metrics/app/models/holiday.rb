class Holiday < ActiveRecord::Base
  validates :holiday_date, presence: true, uniqueness: true
end
